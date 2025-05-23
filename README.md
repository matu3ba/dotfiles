# dotfiles

Actions are performed according to structure of dotfiles, .gitignore, ignorefiles,
win_src_dest, nixos/configuration.nix and hardware-configuration.nix

- `checkHealth.sh` shows status of files
- `fileBackup.sh` create backup to folder `$HOME/back/TIMESTAMP_backconfig` with timestamp if not symlink
- `fileRemove.sh` remove regular files, if existing on system
- `fileRestore.sh` write files, if nonexisting on system, from backup by argument the folder name
- `symlinkInstall.sh` create symlinks and also create folders with symlinks
- `symlinkUninstall.sh` remove symlinks
- `fileOverwrite.ps1` overwrite configurations based on win_src_dest on Windows
- TODO: usage on NixOS

### Dependencies

- readlink to follow symbolic links
- realpath to resolve non-canonical paths provided by fd-find
- fd-find: https://github.com/sharkdp/fd (cargo install fd-find) for convenient ignorelist
  * fd returns relative paths prefixed with ./ to prevent -files from modifying shell behavior
- POSIX-compatible shell
- zig build
  * cross compilation `zig build test -Dno_cross`
    o zig
  * mandatory dependencies `zig build test -Dno_opt_deps`
    o zig
  * optional dependencies `zig build test -Dno_opt_deps`
    o stylua: `cargo install stylua --features lua52`
    o haskell (shellcheck)
    o llvm-tools (clang-format, clang-tidy)
    o luacheck

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
