# Flake Guide based on intuition and (non-)design insights

Bare setup tutorials or guides have no recommendations or routines for quick
setup of "standard tooling" to edit flakes or nix files.
Therefore this guide aims to demonstrate initial experience without such tooling
from a clean setup besides reasonable programming knowledge of functional concepts.
This hopefully shows that the initial default experience is not great based on
documentation/specification (guides and tutorials) and implementation
(debugging output/selection of debugging tooling and methods).

On personal interactions with the online communities I have had plenty of
similar experiences (even though people were generally nice), but that may just
have been bad luck or community place selection.

1. Flakes ought to be pure, so using input like the arch and host is not
recommended.

2.  When learning flakes, how to forward inputs, specifically nixpkgs

2.1 nixpkgs is not part of default forwarded pieces, so things silently break without reasonable
    debugging info
  * with pkgs
  * nixpkgs.legacyPackages.${system}
  * widely used import/hack
```nix
let
  system = "`x86_64-linux`";
  pkgs = import nixpkgs { inherit system; };
in {
  ..
}
```
  * solution: pkg usage not possible, even though system install works => must be symbol forwarding
```nix
environment.systemPackages = builtins.attrValues {
  inherit (nixpkgs.legacyPackages.${system})
    neovim
    git;
};
```

2.2 Interestinly `nixos-wsl.nixosModules.wsl {}` is implicitly `nixos-wsl.nixosModules.wsl({ ... }: {})`

2.3 Most confusing and annoying, examples mention superflous knowledge to not
import, using deprecated default configs including setting system to pkgs
  * all of this besides setting once nixpkgs.hostPlatform is handled by nix
  * no curated set of best practice in multiple minimal flake.nix as real use cases

2.4 Exact use cases after basics for
```nix
outputs = inputs@{ nixpkgs, nixos-wsl, ... } :
{
  wsl = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inp; }
  };
}
```
  * 2 syntaxes for the same thing (no idea), maybe slop
  * making it more explicit what that inputs are being used

2.5 Exact use cases after basics for outputs = { self, nixpkgs, nixos-wsl, ... } : {}
  * overlays
  * other forms of reflection of the module content

2.6 Difference between 2.4 and 2.5 ?
  * self is much more powerful

3. Best practice for shared module or when to choose other abstraction for cross-arch/cross-os flake
  * Dont overthink it, simply make a sharedModule for shared
    configuration.
  * There are too many guides without design rational for evaluation performance,
    debugging experience and complexity reduction.
```nix
  outputs = { nixpkgs, nixos-wsl, ... }:
  let
    sharedModule = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ neovim git ];
    };
  in {
  };
```

4. Problem Bizarre syntax errors are not helpful
   cannot put a module function directly inside the `modules = [ .. ]` list; NixOS
   expects either an attribute set or a function wrapped as a module, so your
   function syntax is being parsed as invalid.
```txt
error: syntax error, unexpected ',', expecting '.' or '='
       at $HOME/dotfiles/flake.nix:104:19:
          103|           sharedModule
          104|           { config, lib, pkgs, modulesPath, ... }: {
when forgetting () brackets around modules
      modules = [
        sharedModule
        { config, lib, pkgs, modulesPath, ... }: {
        }
      ];
solution
      modules = [
        sharedModule
        ({ config, lib, pkgs, modulesPath, ... }: {
        })
      ];
```

5. Wrongly nested arguments lead to unknown options without suggestion (lsp?)
```nix
({ config, lib, pkgs, ... }: {
  home-manager.users."user" = {
    home.programs.gpg.enable = true;
    home-manager.services.gpg-agent = {
      defaultCacheTtl = 34560000;
      enable = true;
      enableScDaemon = false;
      enableSshSupport = true;
      maxCacheTtl = 34560000;
      pinentry.package = pkgs.pinentry-tty;
    };
  };
})
```

6. Documentation is often wrong, ie NixOS WSL has wrong docs on generation of tarballs
   sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder

7. Image and install size of NixOS WSL is ~2 GB, which is very big for a Linux VM.
   Compare that to 500MB for Standard Ubuntu.

8. Podman (and docker) can have userspace networking being out of sync with overlay filesystem state
   resulting in container layers becoming orphaned and permission-denied errors preventing cleanup.
   This happens specifically on NixOS WSL, but also on MacOS and other nested containers, overlays
   or other virtualization technologies with overlay and synchronization bugs.
   In WSL systemd is fragile, namespace complexity high and reboot can lose mount
   state mid-operation. Likewise, Mac virtualization has namespace/mount sync problems.
```sh
# 1 Prevent broken podman on WSL restart
systemctl --user mask podman-restart.service
## update nix-os
systemctl --user unmask podman-restart.service

#2 Fix broken podman container
## 1. Stop podman daemon completely
podman machine stop 2>/dev/null || true
systemctl --user stop podman 2>/dev/null || true
## 2. Unmount any remaining overlays
sudo umount -l /tmp/containers-$USER/overlay/*/diff 2>/dev/null || true
sudo umount -l /tmp/containers-$USER/overlay/*/work 2>/dev/null || true
## 3. Delete with elevated permissions
sudo rm -rf /tmp/containers-$USER/
sudo rm -rf ~/.local/share/containers/
## 4. Restart podman cleanly
podman machine start 2>/dev/null || systemctl --user start podman
```
   General solution to prevent broken containers (push-based garbage collection
   model, atomic transaction log, centralized resource tracking): Use
   systemd-nspawn, Incus or Lima.
   So, basically the solution to virtualization (in unreliable environments) is
   a file system to track actions.
   Update: Systemd offering no inversion of control and the actual pid 1
   potentially messing up things at the worst time point looks bad. Tracking
   all process interactions in file system/database would introduce high costs.
   Hyper-V and pid 1 logs should have hints, but I have not looked into them
   for debugging.

9. There is no overview/excellent guide on virtualization in NixOS, which would have saved
   me significant time instead of slowly asking LLMs answer by answer. Further, I would
   expect from a excellent virtualization environment to have a mode to detect such
   problems, but neither docker or podman offer such functionality.
   Maybe, once file systems are moved to user space, better tools will be made.
   Update: Docker and podman have a bad build (cwd-dependent, very limited,
   error prone), deploy (no concept), execution (configuration translation
   from/to kubernetes impossible, very limited, error prone) system and
   do not document container build- and runtime-dependencies semantics
   as provided by underlying tooling. Likewise, docker and podman have very
   limited introspection (only logs) into containers and the runtimes as
   documented standard process for developers.

10. The name `legacyPackages` is bad, because it uses lazy evluation needed by
    the massive attrset (>80k packages). It only exists, because early flake
    proposals wanted outputs based on strict evaluation for simpler reasoning
    and faster CI. More annoyingly, one can often get around usage of
    `legacyPackages` except for cases like `devShells.x86_64-linux.default =
    nixpkgs.legacyPackages.x86_64-linux.mkShell`.

11. Modules can infer `pkgs` from `hostPlatform`, but root steps like dev shells
    have no option to infer it. This is bizarre, because one should be able to infer
    or set it. It is probably related to a missing host and target model and other missing
    pieces like missing abi model leading to nasty behavior on cross-compiling vs native
    compilation of the store and cache.
```nix
{
  description = "Smallish NixOS-WSL flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = { nixpkgs, nixos-wsl, home-manager,... }:
  let
    sharedModule = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ neovim git docker-compose ];
      ..
    };
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      name = "dotfiles ci";
      packages = with pkgs; [ biome curl dotnet-sdk_10 fish opentofu jq ];
      shellHook = ''
        exec ${pkgs.fish}/bin/fish
      '';
    };
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          sharedModule
          nixos-wsl.nixosModules.wsl
          ({ config, lib, pkgs, ... }: {
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = "25.11";
            ..
          })
        ];
      };
    };
  };
}
```

12. Flakes require git versioning to exist. This leads to the requirements
* flake.nix is in git repo `work`
* else: flake.nix is in another git repo `work-flake` with usage options
  - git repo `work` is in file tree of git repo `work-flake` and flake.nix can be used via `nix develop`
    - `work-flake` becomes the "root/integration git repo".
  - flake.nix can be used from git repo work via `nix develop path_to/work-flake`
    - `work-flake` becomes an "uncoupled config" and nix has no database to loosly couple/associate `work-flake` with `work`

13. Core conceptual differences in intended goals and semantics between
    `nix-shell`, `nix develop`, `nix shell` and `nix build` are not (well) communicated.
    As of 20260831, the Nix project is still lacking consolidation into use dense design
    rationale document for use cases and workflows to create conceptual simplicity.
* As far as I understand it, `nix build` was the initial and steadily improved
  production build mode for hermetic builds and `nix-shell` for the "interactive shell stuff".
* Then `nix-shell` got separated into
  - 1 `nix develop` for stage-based development shell with build environment.
    * Build environment is based on `mkShell`/`mkShellNoCC` selection.
  - 2 `nix shell` for `PATH`-only prepend shell without build environment.
  - 3 `nix run` to resolve to an executable path and execute it directly.
* Most annoying during development are host and target system leaks of `PATH`,
  shell config and env vars. Rule of thumb to host/target system shells should
  **only append** to `PATH` (`nix develop/shell` prepend to `PATH`), ideally
  never be nested and do as few as reasonable.
  - I am unaware of a collection of all shell workarounds.
* Nix does not model isolation/sandboxing (not even in hermetic builds), so
  various workarounds may be needed.

14. Essential workflows sorted roughly from less to more isolation. Nix only
    has (fully) hermetic and sandboxed builds, iff installed accordingly.
* quickly execute binaries based on (flake) output: `nix run nixpkgs#hello`
  - adds to `PATH` and executes binary
  - no build-time and run-time isolation
* full interactive environment shell setup within nix
```nix
devShells.${system}.strict = pkgs.mkShellNoCC {
  strictDeps = true; # needed when cross-compiling
  packages = [ python311 pkgs.black ];
};
#>nix develop .#strict
# or use devShells.${system}.default to omit .#strict
```
  - host shell `~/.bashrc` likely already loaded and leaks in
  - env vars leak in
  - replaces `PATH` (may include host paths wrapped through stdenv)
  - `shellHook`, `stdenv/setup` sourced before shell prompt, `~/.bashrc`
  - sets env vars and shell functions for building derivations directly
* minimal interactive environment shell setup within nix
```nix
packages.${system}.dev-env = pkgs.buildEnv {
  name = "dev-environment";
  paths = with pkgs; [
    jq shellcheck
    nil deadnix statix nixfmt
  ];
};
#>nix shell .#dev-env
```
  - host shell `~/.bashrc` likely already loaded and leaks in
  - env vars leak in
  - only prepends `PATH`, no `shellHook`, no `stdenv/setup`, no `~/.bashrc`
  - same idea as external tool `nix-devenv`
* filtering interactive environment shells
  - option `--ignore-environment/-i` to filter env vars
    * keeps only essential env vars, so might need `--keep` to keep some
  - option `--command/-c` starts command/binary with arguments instead of a shell
    and a cleaned up `PATH`
    * since no bash is expected, no nix bashFunctions are sourced
    * to start bash without using `~/.bashrc` leaks including from host shell
      and with cleaned `PATH` use one of
      - `nix develop --ignore-environment --keep HOME --command bash --norc`
        This still does setup stdenv vars, nix bashFunctions `shellHook`.
        With `--command non-bash`, only bash vars are kept.
      - `nix shell --ignore-environment --keep HOME --command bash --norc`
        This still does not setup stdenv vars, nix bashFunctions, `shellHook`.
    * reproducible: identical env vars every time, iff input env vars
      identical and command/binary has reproducible execution
* hermetic builds
  - comparable to podman container run-time security with good setup
    * personally did not test network and orchestration yet in comparison to
      container build systems and Kubernetes
  - sandbox configuration is [hidden input](https://fzakaria.com/2026/07/30/the-nix-sandbox-is-a-hidden-input)
  - many options for various use cases with possible simplifications
    * local (without cache) `runCommandLocal` here with `zig-flake.url = github:silversquirl/zig-flake`
```nix
packages.${system}.zig-build-test-all = pkgs.runCommandLocal "zig-build-test-all" {
  src = ./.;
  nativeBuildInputs = [ zig-flake.packages.${system}.nightly ];
} ''
  export ZIG_LOCAL_CACHE_DIR="$TMPDIR/.zig-cache/"
  export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/.cache/zig"
  mkdir -p "$ZIG_LOCAL_CACHE_DIR" "$ZIG_GLOBAL_CACHE_DIR"
  cd "$src"
  zig build test --summary all
  touch "$out"
'';
#>nix build #.zig-build-test-all
```
    * TODO

15. Looking into OCI security, SBOM and how Nix tries to deal with it,
shows quickly that Nix always worked around the problem via it own controlled
sandbox and that the OCI specification is very insufficient to create
composable environments and composable security.
Nix has Nucleus, which can check and enforce runtime semantics, but
no converter (only kubnix and kubernix exist).
OCI has at least mount configurations for binds to adjust to the user id,
but docker does not implement.
OCI has neither tooling nor convention to specify or compose the security
basics starting with the `USER` `id`, `gid` being statically or dynamically
used for tooling with typical use cases of assertions, composition/build
system, search. Automatic permission generation, supervision and policy
creation would be other interesting pieces.
Therefore strategies are
* 1 has to static checks for the user assumptions (for docker)
```Dockerfile
FROM docker.io/library/node:26-alpine
ARG UID
ARG GID

# 1 /etc/passwd must contain
# root:x:0:0:root:/root:/bin/sh
# $USER:x:UID:GID::/home/$USER:/bin/sh
# 2 /home/$USER must be empty
# 3 UID and GID in container must match
RUN set -e; \
    echo "=== Validating /etc/passwd ===" && \
    PASSWD_LINES=$(grep '/bin/sh$' /etc/passwd) && \
    COUNT=$(echo "$PASSWD_LINES" | wc -l) && \
    if [ "$COUNT" -eq 2 ]; then echo "[OK] Found exactly 2 entries with /bin/sh"; else echo "[FAIL] Expected 2 entries with /bin/sh, found $COUNT"; exit 1; fi && \
    if echo "$PASSWD_LINES" | grep -q '^root:x:0:0:root:/root:/bin/sh$'; then echo "[OK] root entry valid"; else echo "[FAIL] root entry malformed"; exit 1; fi && \
    if echo "$PASSWD_LINES" | grep -q "^[^:]*:x:${UID}:${GID}::/home/[^:]*:/bin/sh$"; then echo "[OK] Non-root entry valid (UID=${UID}, GID=${GID})"; else echo "[FAIL] Non-root entry with UID=${UID} GID=${GID} not found"; exit 1; fi && \
    NON_ROOT_USER=$(echo "$PASSWD_LINES" | grep -v '^root:' | cut -d: -f1) && \
    echo "[OK] Extracted user: $NON_ROOT_USER" && \
    echo "=== Validating /home ===" && \
    UNEXPECTED=$(find /home -mindepth 1 -maxdepth 1 ! -name "$NON_ROOT_USER" 2>/dev/null || true) && \
    if [ -z "$UNEXPECTED" ]; then echo "[OK] /home clean"; else echo "[FAIL] Unexpected entries in /home"; exit 1; fi && \
    if [ ! -d "/home/$NON_ROOT_USER" ] || [ -z "$(find "/home/$NON_ROOT_USER" -type f 2>/dev/null)" ]; then echo "[OK] /home/$NON_ROOT_USER empty"; else echo "[FAIL] /home/$NON_ROOT_USER is not empty"; exit 1; fi && \
    echo "=== Validating UID + GID match ===" && \
    USER_ID=$(id -u "$NON_ROOT_USER") && \
    USER_GID=$(id -g "$NON_ROOT_USER") && \
    if [ "$USER_ID" = "$UID" -a "$USER_GID" = "$GID" ]; then echo "[OK] User UID, GID matches"; else echo "[FAIL] UID, GID mismatch: expected $UID/$GID, got $USER_ID/$USER_GID"; exit 1; fi && \
    echo "[OK] All validations passed"

WORKDIR /app
RUN mkdir -p /app/node_modules && chown -R ${UID}:${GID} /app
USER ${UID}:${GID}
```
* 2 Use uidMappings / gidMappings on mounts as specified by OCI if tool supports it
  after parsing out container uid/gid and/or setting user.
  - podman has uidmap, gidmap, see https://docs.podman.io/en/latest/markdown/podman-run.1.html
* 3 do non-root user setup yourself based on a bare container without users
  - OCI has on semantic convention on this like it has no semantic convention
    on run-time security.
