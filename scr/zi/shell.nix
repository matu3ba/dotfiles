{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/01441e14af5e29c9d27ace398e6dd0b293e25a54.tar.gz") {} }:
pkgs.stdenvNoCC.mkDerivation {
  name = "shell";
  nativeBuildInputs = with pkgs; [
      gdb
      python3
      qemu
      rr
      valgrind
      wasmtime
  ];
  PROJECT_ROOT = builtins.toString ./.;
  shellHook = ''
    PATH=$PATH:$PROJECT_ROOT/../zdev/zig/master/rel/bin/
    PATH=$PATH:$PROJECT_ROOT/../zdev/zls/zig-out/bin/
    PATH=$PATH:$PROJECT_ROOT/../zdev/ztags/zig-out/bin/
    PATH=$PATH:$PROJECT_ROOT/../zdev/jfind/build/
  '';
}