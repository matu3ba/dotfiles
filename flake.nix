#==wsl
#====wsl_setup nixos.wsl to usable for user name
# 0 wsl --install --no-distribution && wsl --install --from-file nixos.wsl && wsl -d NixOS
# 1 sudo nixos-rebuild boot --flake .#wsl
# 2 wsl -t NixOS
# 3 wsl -d NixOS --user root exit
# 4 wsl -t NixOS
# 5 user was setup, start NixOS: wsl -s NixOS
#====wsl_setup tarball to usable
# sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder
#====wsl_usage
# install: sudo nixos-rebuild switch --flake .#wsl
# update: nix flake update
# * if necessary: nix-channel --update
# revert: git restore -s COMMIT flake.nix
# * if necessary: wsl -d NixOS.Dev --user root
# pin: update flake.lock
# check: nix flake check
#==station
#====station_setup
# idea generate hardware setup with detection + how to store it properly
#====station_usage
# sudo nixos-rebuild switch --flake .#station
# see ====wsl_usage

#==generators
# nix run github:nix-community/nixos-generators -- --format qcow --flake .#vm1

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

# nix-store --delete --ignore-liveness result/ && rm result
# nix-store --query --roots result/

# related: nix show-derivation --recursive .#wsl
# nix show-derivation STORE_PATH_gcc | jq '.[].outputs'

# nix store diff-closures /nix/var/nix/profiles/system-655-link /nix/var/nix/profiles/system-658-link

# last resort debug: grep -R "STORE_PATH" /nix/store/*.drv
#==hot_fix
# nix-store --verify --check-contents --repair

#==search
# https://search.nixos.org/packages better: nix search nixpkgs fd

{
  description = "Smallish NixOS-WSL flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-index-database.url = "github:nix-community/nix-index-database"; # locate pkg in nixpkgs
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # inputs.nur.url = "github:nix-community/NUR";
  };

  outputs = { nixpkgs, nixos-wsl, home-manager,... }:
  let
    sharedModule = { pkgs, ... }: {
      # packages maven javaPackages.compiler.openjdk17
      # podman-compose not yet sufficiently compatible
      environment.systemPackages = with pkgs; [ neovim git docker-compose opentofu ];
      # podman needs /etc/subuid, /etc/subgid
      environment.extraInit = ''
        if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
          export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
        fi
      ''; # docker-compose for $USER

      virtualisation = {
        containers.enable = true;
        containers.storage.settings = {
          storage = {
            driver = "overlay";
            runroot = "/run/containers/storage";
            graphroot = "/var/lib/containers/storage";
            rootless_storage_path = "/tmp/containers-$USER";
            options.overlay.mountopt = "nodev,metacopy=on";
          };
        };
        oci-containers.backend = "podman";
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      }; # podman via docker-compose for $USER

      documentation.enable = true;

      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
      nix.settings.auto-optimise-store = true;

    };
    # sharedHomeModule = { pkgs, ... }: {
    #   # TODO shared home module used as
    # };
  in {
    nixosConfigurations = {
      wsl = nixpkgs.lib.nixosSystem {
        modules = [
          sharedModule
          nixos-wsl.nixosModules.wsl
          ({ config, lib, pkgs, ... }: {
            nixpkgs.hostPlatform = "x86_64-linux";
            system.stateVersion = "25.11";

            hardware.enableAllFirmware = false;
            boot.isContainer = true;
            networking.networkmanager.enable = false;
            services.openssh.enable = false;

            programs.fish.enable = true;
            environment.pathsToLink = ["/share/fish"];
            environment.shells = [pkgs.fish];
            environment.enableAllTerminfo = true;

            networking.hostName = "nixos_wsl";
            users.users."jan-philipp.hafer" = {
              isNormalUser = true;
              shell = pkgs.fish;
              extraGroups = [
                "wheel"
                "docker"
              ];
              # hashedPassword = "";
              # openssh.authorizedKeys.keys = [
              #   "ssh-rsa ..."
              # ]; # ssh public key
            };

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

          })
          home-manager.nixosModules.home-manager
          ({ config, lib, pkgs, ... }: {
            # wrong, must be inputs (stateless eval)
            # username = "jan-philipp.hafer";
            # hostname = "nixos_wsl";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [];
            # import ./home-manager/home.nix; evaluates purely in home-manager/, so
            # home.file > "../file" is broken
            # home-manager.users."jan-philipp.hafer" = import ./home-manager/home.nix;
            home-manager.users."jan-philipp.hafer" = {
              home.username = "jan-philipp.hafer";
              home.homeDirectory = "/home/jan-philipp.hafer";
              home.stateVersion = "25.11";

              home.file = {
                "./.config/" = {
                    source = ./.config;
                    recursive = true;
                };
                "./.bashrc".source = ./.bashrc;
              };

              home.sessionVariables = {
                EDITOR = "nvim";
              };
              # export GPG_TTY=$(tty)
              # set -gx GPG_TTY "$(tty)"
              programs.gpg.enable = true;
              services.gpg-agent = {
                defaultCacheTtl = 34560000;
                enable = true;
                enableScDaemon = false;
                enableSshSupport = true;
                maxCacheTtl = 34560000;
                pinentry.package = pkgs.pinentry-tty;
              };

              home.packages = [
                pkgs.fd
                pkgs.fish
                pkgs.ripgrep
              ];
            };
            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          })
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
            networking.hostName = "nixos_station";
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
