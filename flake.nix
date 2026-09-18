#==wsl
#==dev

#==wsl
#====wsl_usage
# install best: nixos-rebuild switch --sudo --flake .#wsl
# install workaround on activation problems:
# * nixos-rebuild boot --sudo --flake .#wsl
# * sudo shutdown -r now
# * sudo /run/current-system/activate
# * sudo /run/current-system/bin/switch-to-configuration switch
# update: nix flake update
# * if necessary: nix-channel --update
# revert: git restore -s COMMIT flake.nix
# * if necessary: wsl -d NixOS.Dev --user root
# pin: update flake.lock
# check: nix flake check
#====wsl_setup nixos.wsl to usable for user name
# 0 wsl --install --no-distribution && wsl --install --from-file nixos.wsl && wsl -d NixOS
# 1 nixos-rebuild boot --sudo --flake .#wsl
# 2 wsl -t NixOS
# 3 wsl -d NixOS --user root exit
# 4 wsl -t NixOS
# 5 user was setup, start NixOS: wsl -s NixOS
#====wsl_setup tarball to usable
# sudo nix run .#nixosConfigurations.wsl.config.system.build.tarballBuilder
#==station
#====station_setup
# idea generate hardware setup with detection + how to store it properly
#====station_usage
# nixos-rebuild switch --sudo --flake .#station
# see ====wsl_usage
# nixos-rebuild
# --target-host requires host access via ssh + switch, boot, test need root access

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
# nix why-depends --derivation .#nixosConfigurations.wsl.config.system.build.toplevel .#nixosConfigurations.wsl.pkgs.MYPKG
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
# sudo nix-store --verify --check-contents --repair
# sudo nix-store --verify --check-contents --repair --check-contents

#==search
# https://search.nixos.org/packages better: nix search nixpkgs fd

#==troubleshooting
#====WSL systemd reload failure (D-Bus reloading during live switch very fragile due to session bus tied to running shell/user)
#1 systemctl --user status dbus-broker.service
#2 systemctl --user restart dbus-broker.service
#3 reapply config. it should return without error.

# nixos-rebuild switch problems:
# build logs: --print-build-logs, activation logs: add -L
# --verbose, --show-trace, -v

# > nix why-depends .#nixosConfigurations.wsl.config.system.build.toplevel nixpkgs#dbus-broker
# /nix/store/hvjh93g31b129ssi2yp0wxrmadg2jsq4-nixos-system-nixos_wsl-26.05.20260630.95ca1e2
# └───/nix/store/rwx4swanl5kjrsx6rqzpb6y85718lf9l-system-path
# ╎   └───/nix/store/49x6wkrr41xqc4imyd2m8vdm9k8pl73p-dbus-broker-37
# Find what's in system-path that depends on dbus-broker
# nix-store --query --requisites /nix/store/rwx4swanl5kjrsx6rqzpb6y85718lf9l-system-path | grep -E '(dbus|broker)'
# What directly references dbus-broker?
# nix-store --query --referrers /nix/store/49x6wkrr41xqc4imyd2m8vdm9k8pl73p-dbus-broker-37

# ls -la ~/.config/systemd/user/
# systemctl list-dependencies service

#==dev
# devShells
# * nix develop --ignore-environment --keep HOME
# * nix develop --ignore-environment --keep HOME --command bash --norc
# checks (checks.${system}.CHECKNAME = ..)
# * nix flake check -L
# package builds (packages.${system}.PKGNAME = ..)
# * nix build .#zig-build-test-all

{
  description = "Smallish NixOS-WSL flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    zig-flake.url = "github:silversquirl/zig-flake";
    # nix-index-database.url = "github:nix-community/nix-index-database"; # locate pkg in nixpkgs
    # nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    # inputs.nur.url = "github:nix-community/NUR";
  };

  outputs =
    {
      nixpkgs,
      nixos-wsl,
      home-manager,
      zig-flake,
      ...
    }:
    let
      sharedModule = { pkgs, ... }: {
        # packages maven javaPackages.compiler.openjdk17
        environment.systemPackages = with pkgs; [
          neovim
          git
          jq
        ];

        documentation.enable = true;

        # lix (stable,latest,git,lix_2_93,etc)
        nixpkgs.overlays = [
          (_: prev: {
            inherit (prev.lixPackageSets.stable)
              nixpkgs-review
              nix-eval-jobs
              nix-fast-build
              colmena
              ;
          })
        ];
        nix = {
          package = pkgs.lixPackageSets.stable.lix;
          settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 1w";
          };
          settings.auto-optimise-store = true;
        };

      };
      # Host, Target and ABI are incoherent in Nix. Need this for top level steps
      # like devShells.x86_64-linux.default
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # sharedHomeModule = { pkgs, ... }: {
      #   # TODO shared home module used as
      # };
    in
    {

      # luaPackages.luacheck, lua-language-server
      # nixd
      devShells.${system}.default = pkgs.mkShellNoCC {
        name = "dotfiles ci";
        packages = with pkgs; [
          curl
          jq
          fish
          (texlive.combined.scheme-basic.withPackages (
            ps: with ps; [
              parskip
              enumitem
            ]
          ))
          # shell-tools
          shellcheck
          # c/c++-tools
          clang-tools
          # python-tools
          uv # for uvx
          # dotnet-tools
          dotnet-sdk_10
          # typescript-tools
          biome
          # container-tools (docker, compose, k8, images)
          docker-language-server
          # kics (lint k8s, etc)
          trivy
          # terraform
          tofu-ls
          opentofu
          # nix-tools
          nil
          deadnix
          statix
          nixfmt
          # lua-tools
          emmylua-check
          emmylua-ls
          stylua
        ];
        buildInputs = [ zig-flake.packages.${system}.nightly ]; # (cross-)compilation
      };
      packages.${system}.zig-build-test-all =
        pkgs.runCommandLocal "zig-build-test-all"
          {
            src = ./.;
            nativeBuildInputs = [ zig-flake.packages.${system}.nightly ];
          }
          ''
            export ZIG_LOCAL_CACHE_DIR="$TMPDIR/.zig-cache/"
            export ZIG_GLOBAL_CACHE_DIR="$TMPDIR/.cache/zig"
            mkdir -p "$ZIG_LOCAL_CACHE_DIR" "$ZIG_GLOBAL_CACHE_DIR"
            cd "$src"
            zig build test --summary all
            touch "$out"
          '';

      nixosConfigurations = {
        wsl = nixpkgs.lib.nixosSystem {
          modules = [
            sharedModule
            nixos-wsl.nixosModules.wsl
            (
              {
                pkgs,
                ...
              }:
              {
                # security.shadow.enable = true; # should be default and enables rootless subuid/subgid
                nixpkgs.hostPlatform = "x86_64-linux";
                system.stateVersion = "25.11";

                hardware.enableAllFirmware = false;
                boot.isContainer = true;
                networking.networkmanager.enable = false;
                services.openssh.enable = false;

                programs.fish.enable = true;
                environment = {
                  pathsToLink = [ "/share/fish" ];
                  shells = [ pkgs.fish ];
                  enableAllTerminfo = true;
                };

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

                #==/etc/wsl.conf
                wsl = {
                  enable = true;
                  defaultUser = "jan-philipp.hafer"; # getEnv + username makes flake evaluation impure
                  # docker desktop, extraBin, extraBin copy/name/src, extraBin name
                  # interop.includePath/register
                  # ssh-agent enable/package/users
                  # startMenuLaunchers
                  # tarball.configPath
                  # usbip enable/autoAttach/snippetIpAddress
                  # useWindowsDriver (OpenGL)
                  wrapBinSh = true;
                  wslConf = {
                    automount = {
                      enabled = true;
                      # wsl.wslConf.ldconfig = false; errors on usage
                      mountFsTab = false; # probably leave false, systemd will mount these
                      options = "metadata,uid=1000,gid=100";
                      root = "/mnt";
                    };
                    boot.systemd = true; # disabling may break NixOS installation
                    interop.enabled = true;
                    interop.appendWindowsPath = true;
                    network = {
                      generateHosts = true;
                      # manual host creation, config taken from WSL generateHosts=true
                      # networking.hosts = {
                      #   # ipv4
                      #   # keycloak for https://github.com/wkrzywiec/keycloak-security-example
                      #   "127.0.0.1" = ["localhost" "keycloak"];
                      #   "127.0.1.1" = ["nixoswsl"];
                      #   # ipv6
                      #   "::1"     = ["ip6-localhost ip6-loopback"];
                      #   "fe00::0" = ["ip6-localnet"];
                      #   "ff00::0" = ["ip6-mcastprefix"];
                      #   "ff02::1" = ["ip6-allnodes"];
                      #   "ff02::2" = ["ip6-allrouters"];
                      # };
                      generateResolvConf = true;
                      hostname = "nixos_wsl";
                    };
                    user.default = "jan-philipp.hafer";
                  };
                };
                #==quickfix wsl-nixos
                # override /run/systemd/generator/wsl-mnt-guard.service to use nixos /bin/true /bin/mount
                # to workaround WSL 2.9.9.0 behavior that fixes https://github.com/nix-community/NixOS-WSL/issues/1074
                systemd.services."wsl-mnt-guard" = {
                  overrideStrategy = "asDropin";
                  unitConfig.ConditionPathIsMountPoint = "/mnt/wsl";
                  serviceConfig = {
                    ExecStart = [
                      ""
                      "${pkgs.coreutils}/bin/true"
                    ];
                    ExecStop = [
                      ""
                      "-${pkgs.util-linux}/bin/mount --make-rslave /mnt/wsl"
                    ];
                  };
                };

                #==virtualisation: workaround unreliable systemd in WSL for rootless podman
                # https://github.com/podman-container-tools/podman/blob/main/docs/tutorials/rootless_tutorial.md

                # podman needs /etc/subuid, /etc/subgid
                virtualisation = {
                  podman = {
                    enable = true;
                    dockerCompat = true; # Adds 'docker' alias for 'podman'
                    defaultNetwork.settings.dns_enabled = true;
                    # dockerSocket.enable = true is unreliable in WSL2
                  };
                  containers = {
                    enable = true;
                    storage.settings = {
                      storage = {
                        driver = "overlay";
                      };
                      # nixos only supports cgroup v2 with systemd as default manager
                      # cgroupManager = "cgroupfs";
                    };
                  };
                };

                # Install required packages
                environment.systemPackages = with pkgs; [
                  podman-compose # Use podman-compose, not docker-compose
                  passt # Explicit installation for WSL2
                ];

                # Set DOCKER_HOST on login so podman compose finds the socket.
                # This is necessary because systemd.user.sockets is unreliable in WSL2
                # and socket creation is managed by systemd.user.sockets.
                environment.extraInit = ''
                  export PODMAN_COMPOSE_WARNING_LOGS=false
                  if [ -z "$DOCKER_HOST" -a -n "$XDG_RUNTIME_DIR" ]; then
                    export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"
                  fi
                '';

                # Dont use any of these in WSL2:
                # - virtualisation.oci-containers (default systemd integration)
                # - systemd.user.sockets.podman (uses systemd service)
                # - services.podman.* (Home Manager, uses systemd podman service)
                # - virtualisation.containers.storage.settings.cgroupManager = "systemd"

                # Instead, manage containers with:
                # - podman compose (manual docker-compose.yml files)
                # - Nix scripts that call podman directly
              }
            )
            home-manager.nixosModules.home-manager
            (
              {
                pkgs,
                ...
              }:
              {
                # wrong, must be inputs (stateless eval)
                # username = "jan-philipp.hafer";
                # hostname = "nixos_wsl";
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  sharedModules = [ ];
                  # import ./home-manager/home.nix; evaluates purely in home-manager/, so
                  # home.file > "../file" is broken
                  # home-manager.users."jan-philipp.hafer" = import ./home-manager/home.nix;
                  users."jan-philipp.hafer" = {
                    home = {
                      username = "jan-philipp.hafer";
                      homeDirectory = "/home/jan-philipp.hafer";
                      stateVersion = "25.11";

                      file = {
                        "./.config/" = {
                          source = ./.config;
                          recursive = true;
                        };
                        "./.bashrc".source = ./.bashrc;
                      };

                      sessionVariables = {
                        EDITOR = "nvim";
                      };
                      packages = [
                        pkgs.fd
                        pkgs.fish
                        pkgs.ripgrep
                      ];
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

                  };
                  # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
                };
              }
            )
          ];
        };
        station = nixpkgs.lib.nixosSystem {
          modules = [
            sharedModule
            (
              {
                config,
                pkgs,
                modulesPath,
                ...
              }:
              {
                # hardware-config
                imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

                boot = {
                  initrd.availableKernelModules = [
                    "nvme"
                    "xhci_pci"
                    "ahci"
                    "usb_storage"
                    "usbhid"
                    "sd_mod"
                  ];
                  initrd.kernelModules = [ ];
                  kernelModules = [
                    "kvm-amd"
                    "v4l2loopback"
                  ];
                };
                fileSystems = {
                  "/" = {
                    device = "/dev/disk/by-uuid/5c732e8c-9d09-46b0-8611-1d75679e16e7";
                    fsType = "ext4";
                  };
                  "/boot" = {
                    device = "/dev/disk/by-uuid/678C-B2DB";
                    fsType = "vfat";
                  };
                };
                swapDevices = [ ];
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
                fileSystems."/".options = [
                  "noatime"
                  "nodiratime"
                  "discard"
                ];
                networking = {
                  useDHCP = true;
                  hostName = "nixos_station";
                  wireless.enable = true; # wpa_supplicant
                };
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
                  extraGroups = [
                    "wheel"
                    "input"
                  ]; # allow 'sudo' for user
                };

                services.openssh = {
                  enable = true;
                  settings.PasswordAuthentication = false;
                };
              }
            )
          ];
        };
      };
    };
}
