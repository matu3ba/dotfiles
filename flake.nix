#==setup for user name
# 1 sudo nixos-rebuild boot --flake .#wsl
# 2 wsl -t NixOS
# 3 wsl -d NixOS --user root exit
# 4 wsl -t NixOS
# 5 user was setup, start NixOS: wsl -s NixOS
#==usage
# install: sudo nixos-rebuild switch --flake .#wsl
# update: nix flake update
# * if necessary: nix-channel --update
# revert: git restore -s COMMIT flake.nix
# * if necessary: wsl -d NixOS.Dev --user root
# pin: update flake.lock
# check: nix flake check

#==keep_small_store_debug
# du -sh /nix/store/* | sort -h
# nix path-info -Sh /run/current-system
# nix-store --query --referrers-closure /nix/store/some_path
# nix-store --query --referrers STORE_PATH_rustc
# nix-store --query --requisites /run/current-system | grep -E 'gcc|rustc|llvm'
##why-depends x on y at runtime?
# nix why-depends /run/current-system nixpkgs#curl.bin
##why-depends x on y at build time?
# nix why-depends --derivation /run/current-system nixpkgs#curl.bin
# other example: nix why-depends .#simple_package github:nixos/nixpkgs#python310
## why-depends does not explain /nix/store entries for flakes/non-nixpkg registry entry
# nix why-depends /run/current-system $(nix-store --query --requisites /run/current-system | grep gcc)

# related: nix show-derivation --recursive .#wsl
# nix show-derivation STORE_PATH_gcc | jq '.[].outputs'

# nix store diff-closures /nix/var/nix/profiles/system-655-link /nix/var/nix/profiles/system-658-link

# last resort debug: grep -R "STORE_PATH" /nix/store/*.drv
#==hot_fix
# nix-store --verify --check-contents --repair

{
  description = "Smallish NixOS-WSL flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = { nixpkgs, nixos-wsl, ... }: {
    nixosConfigurations = {
      # inherit nixpkgs;
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          nixos-wsl.nixosModules.wsl
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = "25.11";

            hardware.enableAllFirmware = false;

            boot.isContainer = true;
            networking.networkmanager.enable = false;
            services.openssh.enable = false;
            documentation.enable = true;

            wsl.enable = true;
            wsl.defaultUser = "jan-philipp.hafer"; # getEnv + username makes flake evaluation impure
            # docker desktop, extraBin, extraBin copy/name/src, extraBin name
            # interop.includePath/register
            # ssh-agent enable/package/users
            # startMenuLaunchers
            # tarball.configPath
            # usbip enable/autoAttach/snippetIpAddress
            # useWindowsDriver (OpenGL)
            wsl.wrapBinSh = true;
            wsl.wslConf.automount.enabled = true;
            # wsl.wslConf.ldconfig = false; errors on usage
            wsl.wslConf.automount.mountFsTab = false; # probably leave false, systemd will mount these
            wsl.wslConf.automount.options = "metadata,uid=1000,gid=100";
            wsl.wslConf.automount.root = "/mnt";
            wsl.wslConf.boot.systemd = true; # disabling may break NixOS installation
            wsl.wslConf.interop.enabled = true;
            wsl.wslConf.interop.appendWindowsPath = true;
            wsl.wslConf.network.generateHosts = true;
            wsl.wslConf.network.generateResolvConf = true;
            wsl.wslConf.network.hostname = "nixos";
            wsl.wslConf.user.default = "jan-philipp.hafer";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            nix.gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 1w";
            };
            nix.settings.auto-optimise-store = true;
          }
        ];
      };
      # amd64linux = nixpkgs.lib.nixosSystem {
      #   # example
      # };
    };
  };
}
