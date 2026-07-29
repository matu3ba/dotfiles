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
    * widely used import/ hack
      let
        system = "`x86_64-linux`";
        pkgs = import nixpkgs { inherit system; };
      in {
        ..
      }
    * solution: pkg usage not possible, even though system install works => must be symbol forwarding
      environment.systemPackages = builtins.attrValues {
        inherit (nixpkgs.legacyPackages.${system})
          neovim
          git;
      };
2.2 nixos-wsl.nixosModules.wsl {} is implicitly nixos-wsl.nixosModules.wsl({ ... }: {})
2.3 Most confusing and annoying, examples mention superflous knowledge to not import, using
    deprecated default configs including setting system to pkgs
    * all of this besides setting once nixpkgs.hostPlatform is handled by nix
    * no curated set of best practice in multiple minimal flake.nix as real use cases
2.4 Exact use cases after basics for outputs = inputs@{ nixpkgs, nixos-wsl, ... } :
{
  wsl = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inp; }
  };
}
    * 2 syntaxes for the same thing (no idea), maybe slop
    * making it more explicit what that inputs are being used
2.5 Exact use cases after basics for outputs = { self, nixpkgs, nixos-wsl, ... } : {}
    * overlays
    * other forms of reflection of the module content
Difference between 2.4 and 2.5 ?
    * self is much more powerful

3. Best practice for shared module or when to choose other abstraction for cross-arch/cross-os flake
    * Dont overthink it, simply make a sharedModule for shared
      configuration.
    * There are too many guides without design rational for evaluation performance,
      debugging experience and complexity reduction.
      outputs = { nixpkgs, nixos-wsl, ... }:
      let
        sharedModule = { pkgs, ... }: {
          environment.systemPackages = with pkgs; [ neovim git ];
        };
      in {
      };

4. Problem Bizarre syntax errors are not helpful
   cannot put a module function directly inside the modules = [ … ] list; NixOS
   expects either an attribute set or a function wrapped as a module, so your
   function syntax is being parsed as invalid.
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

5. Wrongly nested arguments lead to unknown options without suggestion (lsp?)
          ({ config, lib, pkgs, ... }: {
            home-manager.users."jan-philipp.hafer" = {
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
   ```
   1 Prevent broken podman on WSL restart
   systemctl --user mask podman-restart.service
   # update nix-os
   systemctl --user unmask podman-restart.service

   2 Fix broken podman container
   # 1. Stop podman daemon completely
   podman machine stop 2>/dev/null || true
   systemctl --user stop podman 2>/dev/null || true
   # 2. Unmount any remaining overlays
   sudo umount -l /tmp/containers-$USER/overlay/*/diff 2>/dev/null || true
   sudo umount -l /tmp/containers-$USER/overlay/*/work 2>/dev/null || true
   # 3. Delete with elevated permissions
   sudo rm -rf /tmp/containers-$USER/
   sudo rm -rf ~/.local/share/containers/
   # 4. Restart podman cleanly
   podman machine start 2>/dev/null || systemctl --user start podman
   ```
   General solution to prevent broken containers (push-based garbage collection
   model, atomic transaction log, centralized resource tracking): Use
   systemd-nspawn, Incus or Lima.
   So, basically the solution to virtualization (in unreliable environments) is
   a file system.

9. There is no overview/excellent guide on virtualization in NixOS, which would have saved
   me significant time instead of slowly asking LLMs answer by answer. Further, I would
   expect from a excellent virtualization environment to have a mode to detect such
   problems, but neither docker or podman offer such functionality.
   Maybe, once file systems are moved to user space, better tools will be made.

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
