# Zig application "appname" demonstrating nix project management
Based on https://codeberg.org/Mcrtin/zofa.
```
./example/nix_project_deps/build.zig
./example/nix_project_deps/build.zig.zon
./example/nix_project_deps/build.zig.zon.nix
./example/nix_project_deps/default.nix
./example/nix_project_deps/flake.lock
./example/nix_project_deps/flake.nix
./example/nix_project_deps/shell.nix
./example/nix_project_deps/nix/package.nix
./example/nix_project_deps/nix/devShell.nix
```

## Develop
```
pushd ./example/nix_project_deps/
nix develop
nix shell
zig build -Doptimize=safe
zig build test --watch
nix build
nix run
nix shell "path:$PWD#formatter.x86_64-linux" -c alejandra .
```

## Update dependencies
```
pushd ./example/nix_project_deps/
# update build.zig.zon and nix/package.nix hashes if needed
nix flake update
# 1 flake.lock boilerplate derived from flake-compat and zig-overlay
# 2 before zigDeps lots of boilerplate in build.zig.zon.nix
# from using github:jcollie/zon2nix#zon2nix
# 3 nix flake is horrible for git root relative usage of
# flake.lock when tools not in flake.nix
# 4 devShell.nix, shell.nix, default.nix feels like boilerplate
# to workaround missing flake.nix specification
```

## Reusing in nix

```
# 1 add to nix flake
appname = {
  url = "git+https://codeberg.org/user/appname";
  inputs.nixpkgs.follows = "nixpkgs";
};
# 2 add to packages
inputs.appname.packages.${pkgs.stdenv.hostPlatform.system}.default
```

## zon2nix package
```
pushd ./example/nix_project_deps/
nix run github:jcollie/zon2nix#zon2nix -- --nix=build.zig.zon.nix build.zig.zon
# 2GB space waste, but better than a pile of undebuggable rubbish
# Bear in mind that nix flakes suck horribly for isolation, when tools are not
# managed by it.
# Nix is unable to express git root relative operation like any sane build system
# comparable to container tooling.

# Examples of user hostile behavior
nix shell --inputs-from . nixpkgs#zon2nix -c zon2nix --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix run .#legacyPackages.x86_64-linux.zon2nix -- --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix run --inputs-from "path:$PWD" nixpkgs#zon2nix -- --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix run --inputs-from . nixpkgs#zon2nix -- --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix develop "path:$PWD" -c zon2nix --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix shell "path:$PWD#inputs.nixpkgs.legacyPackages.x86_64-linux.zon2nix" -c zon2nix --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
nix shell --inputs-from "path:$PWD" "flake:nixpkgs#zon2nix" -c zon2nix --nix=build.zig.zon.nix build.zig.zon
error: FileNotFound
```
