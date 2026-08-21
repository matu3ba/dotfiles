# dotfiles

Most relevant commands with config dependencies
* `all commands except for flake.nix ($HOME, ~/dotfiles)`
* `symlinkInstall.sh (ignorefiles, .gitignore)`
* `flake.nix (./.config/, ./.bashrc)`
* `nix configs (nixos/configuration.nix, nixos/hardware-configuration.nix)`
* `fileOverwrite.ps1 (win_src_dest)`

Commands with explanation
- `checkHealth.sh` shows status of files
- `fileBackup.sh` create backup to folder `$HOME/back/TIMESTAMP_backconfig` with timestamp if not symlink
- `fileRemove.sh` remove regular files, if existing on system
- `fileRestore.sh` write files, if nonexisting on system, from backup by argument the folder name
- `symlinkInstall.sh` create symlinks and also create folders with symlinks
- `symlinkUninstall.sh` remove symlinks
- `fileOverwrite.ps1` overwrite configurations based on win_src_dest on Windows
- `flake.nix` NixOS setup/usage wsl/station (`x86_64-linux`)
  * core usage pain points
    - nix language (implementation) bad designed: error msgs bad, slow
    - no authoritative docs on (use case based) code creation design, debugging, core patterns
      * blog posts tend to contain bad patterns and no functional minimal code
      * see flake_nix_bad_but_works.md
    - 2GB container install size, on trimming/potential breakage ~200-300 MB less
    - unusable with containers and default WSL configurations due to bad file corruptions
    - random systemd errors and /nix/store corruptions, but no crashes
      unrelated to virtualization to far
    - standard workflows untested by nixos upstream including releases

### Dependencies

- `readlink` to follow symbolic links
- `realpath` to resolve non-canonical paths provided by fd-find
- `fd-find`: https://github.com/sharkdp/fd (cargo install fd-find) for convenient ignorelist
  * fd returns relative paths prefixed with ./ to prevent -files from modifying shell behavior
- POSIX-compatible shell
- `zig build`
  * without cross compilation: `zig build test -Dno_cross`
  * without optional dependencies: `zig build test -Dno_opt_deps`
  * including all optional dependencies: `zig build test --summary all`
    o nix (install all dependencies): `nix develop`
    o stylua: `cargo install stylua --features lua52`
    o haskell: `shellcheck`
    o llvm-tools: `clang-format`, `clang-tidy`
    o lua: `luacheck`

### Usage

Make sure to place this repository in `${HOME}/dotfiles`.
If you also like that this can not be checked in POSIX, let them know.

Make sure not to mess up your `.bashrc` or equivalent of your login shell.
Keep a copy of your distro and files around on your first try to restore things.

### Path handling and file names

To set an example for proper handling, we use readlink and realpath.
This is a fundamental limitation of any program printing folder and file names,
since `-filenames` are not considered as special.
However they can break programs.
Example: `ls "${filename}"` with filename being `-k` leading to `ls -k`.
See also https://github.com/sharkdp/fd/issues/760 and
https://dwheeler.com/essays/fixing-unix-linux-filenames.html#dashes
