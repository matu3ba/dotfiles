{
  description = "appname - what appname is/does";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    zig-overlay,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (
        system:
          f (
            import nixpkgs {
              inherit system;
            }
          )
      );
  in {
    packages = forAllSystems (pkgs: {
      appname = pkgs.callPackage ./nix/package.nix {};
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.appname;
    });
    devShells = forAllSystems (pkgs: {
      default = pkgs.callPackage ./nix/devShell.nix {
        zig = zig-overlay.packages.${pkgs.stdenv.hostPlatform.system}."0.17.0";
      };
    });
    defaultNix = forAllSystems (pkgs: self.packages.${pkgs.stdenv.hostPlatform.system}.appname);
    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
