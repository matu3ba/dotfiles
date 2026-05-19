# Flake Guide based on intuition and (non-)design insights

1. Flakes ought to be pure, so using input like the arch and host is not
recommended.

2.  When learning flakes, how to forward inputs, specifically nixpkgs
2.1 nixpkgs is not part of default forwarded pieces, so things silently break without reasonable
    debugging info
    * with pkgs
    * nixpkgs.legacyPackages.${system}
    * widely used import/ hack
      let
        system = "x86_64-linux";
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
      configuration
      outputs = { nixpkgs, nixos-wsl, ... }:
      let
        sharedModule = { pkgs, ... }: {
          environment.systemPackages = with pkgs; [ neovim git ];
        };
      in {
      }

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
