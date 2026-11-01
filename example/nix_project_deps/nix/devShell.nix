{
  pkgs,
  zig,
  llvmPackages,
}: let
  runtimeLibs = [
    llvmPackages.openmp
  ];
in
  pkgs.mkShell {
    name = "appname-dev";

    packages = [
      zig
    ];

    buildInputs = runtimeLibs;

    shellHook = ''
      export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH
    '';
  }
