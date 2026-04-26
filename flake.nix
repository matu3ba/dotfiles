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

  outputs = { nixpkgs, nixos-wsl, ... }:
  let
    sharedModule = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ neovim git ];
      documentation.enable = true;

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
      nix.settings.auto-optimise-store = true;
    };
  in {
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          sharedModule
          nixos-wsl.nixosModules.wsl
          {
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = "25.11";

            hardware.enableAllFirmware = false;
            boot.isContainer = true;
            networking.networkmanager.enable = false;
            services.openssh.enable = false;

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
            wsl.wslConf.network.hostname = "nixos_wsl";
            wsl.wslConf.user.default = "jan-philipp.hafer";
          }
        ];
      };
      station = nixpkgs.lib.nixosSystem {
        modules = [
          sharedModule
          ({ config, lib, pkgs, modulesPath, ... }: {
            # hardware-config
            imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

            boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
            boot.initrd.kernelModules = [ ];
            boot.kernelModules = [ "kvm-amd" "v4l2loopback" ];

            fileSystems."/" =
              { device = "/dev/disk/by-uuid/5c732e8c-9d09-46b0-8611-1d75679e16e7";
                fsType = "ext4";
              };
            fileSystems."/boot" =
              { device = "/dev/disk/by-uuid/678C-B2DB";
                fsType = "vfat";
              };
            swapDevices = [ ];
            networking.useDHCP = true;
            # hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;

            # sys-config
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = "25.11";

            boot = {
              loader = {
                # Use the systemd-boot EFI boot loader.
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
                #grub.device = "/dev/nvme0n1";
              };
              tmp.cleanOnBoot = true;
              kernelPackages = pkgs.linuxPackages_latest;
              extraModulePackages = [ config.boot.kernelPackages.v4l2loopback.out ];
              extraModprobeConfig = ''
               options vl2loopback exclusive_caps=1 card
              '';
            };
            fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
            networking.hostName = "nixos_station"; # Define your hostname.
            networking.wireless.enable = true;  # wpa_supplicant
            time.timeZone = "Europe/Berlin";

            i18n.defaultLocale = "en_US.UTF-8";
            console = {
              font = "Lat2-Terminus16";
              keyMap = "de-latin1-nodeadkeys";
              #useXkbConfig = true; # use xkbOptions in tty.
            };

            # services.printing.enable = true; # CUPS

            # TODO nixos-generate-config, https://github.com/NixOS/nixos-hardware, sudo nix-shell -p dmidecode --run "dmidecode -t 11"
            hardware.alsa.enable = true;
            hardware.graphics.enable = true;

            users.users.jan = {
              isNormalUser = true;
              extraGroups = [ "wheel" "input" ]; # allow 'sudo' for user
            };

            services.openssh = {
              enable = true;
              settings.PasswordAuthentication = false;
            };
          })
        ];
      };
    };
  };
}
