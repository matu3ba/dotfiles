# {
#   sources ? import ./npins,
#   system ? builtins.currentSystem,
#   pkgs ? import sources.nixpkgs { inherit system; config = {}; overlays = []; },
# }:
# {
#   package = pkgs.hello;
# }

{
  sources ? import ./npins,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs { inherit system; config = {}; overlays = []; },
}:
rec {
  package = pkgs.hello;
  shell = pkgs.mkShellNoCC {
    inherit package;
    inputsFrom = [ package ];
    packages = with pkgs; [
      npins
    ];
  };
}
