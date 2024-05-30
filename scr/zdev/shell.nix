# from old to new
# 01441e14af5e29c9d27ace398e6dd0b293e25a54
# 0bf3f5cf6a98b5d077cdcdb00a6d4b3d92bc78b5
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/0bf3f5cf6a98b5d077cdcdb00a6d4b3d92bc78b5.tar.gz") {} }:
pkgs.stdenvNoCC.mkDerivation {
  name = "shell";
  nativeBuildInputs = with pkgs; [
      cmake
      gdb
      libxml2
      ninja
      python3
      qemu
      valgrind
      wasmtime
      # llvm 7
      # llvm
      # lld
      # clang
  #];
  ] ++ (with llvmPackages_16; [
    clang
    clang-unwrapped
    lld
    llvm
  ]);
  PROJECT_ROOT = builtins.toString ./.;
  shellHook = ''
    PATH=$PATH:$PROJECT_ROOT/zig/master/rel/bin/
    PATH=$PATH:$PROJECT_ROOT/zls/zig-out/bin/
    PATH=$PATH:$PROJECT_ROOT/ztags/zig-out/bin/
    PATH=$PATH:$PROJECT_ROOT/jfind/build/
  '';
  #hardeningDisable = [ "all" ];
}