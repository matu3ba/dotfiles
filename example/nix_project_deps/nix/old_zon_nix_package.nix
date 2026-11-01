{
  lib,
  stdenv,
  zig,
  makeWrapper,
  callPackage,
  llvmPackages,
}: let
  deps = callPackage ../build.zig.zon.nix {};
in
  stdenv.mkDerivation {
    pname = "appname";
    version = "0.0.1";
    src = ../.;
    nativeBuildInputs = [
      zig
      makeWrapper
    ];
    buildInputs = [
      llvmPackages.openmp
    ];
    # skip the hook's default "-Dcpu=baseline --release=safe" etc,
    # we set our own flags below
    dontSetZigDefaultFlags = true;
    zigBuildFlags = [
      "--system"
      "${deps}"
      "-Dcpu=baseline"
      "-Doptimize=ReleaseFast"
    ];
    postInstall = ''
      wrapProgram $out/bin/appname \
        --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          llvmPackages.openmp
        ]
      }
    '';
    meta = {
      description = "what app does";
      homepage = "https://codeberg.org/user/appname";
      license = lib.licenses.mit;
      mainProgram = "appname";
    };
  }
