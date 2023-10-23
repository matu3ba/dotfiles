# Dev-shell: nix eval --expr '1 + 1'
# Not sure how to print in dev shell path of ${pkgs.pinentry.tty}
# nix-instantiate --eval '<nixpkgs>' -A lib.version

# Installation
# nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
# nix-channel --update
# nix-shell '<home-manager>' -A install
# (outside of nixos the trusted-users = $USER must be in /etc/nix/nix.conf or ~/.config/nix/nix.conf)
# (sudo systemctl restart nix-daemon.service)
# (gpasswd -a $USER nix-users)
# (see manual https://nixos.org/manual/nix/stable/installation/multi-user)
# [installation might still have weird substitutor error messages or no trusted user]

# Uninstalliation
# https://github.com/NixOS/nix/blob/master/doc/manual/src/installation/uninstall.md

# Updating
# home-manager switch
# (nix-channel --update)

# TODO flakes
# https://nix-community.github.io/home-manager/index.html#ch-nix-flakes

# Rollback
# home-manager generations
# /nix/store/mv960kl9chn2lal5q8lnqdp1ygxngcd1-home-manager-generation/activate


{ config, pkgs, ... }:

{
  home.username = "jan";
  home.homeDirectory = "/home/jan";
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = [
    #====sys
    # find keyboard (linux keyboard tools)
    #find "$(nix eval --raw 'nixpkgs#kbd')/share/keymaps" -name '*.map.gz' | grep de
    pkgs.gnupg
    pkgs.pinentry

    #====desktop_env
    pkgs.arcanPackages.arcan
    pkgs.arcanPackages.cat9
    pkgs.arcanPackages.durden
    pkgs.arcanPackages.xarcan

    #====browser
    pkgs.lynx

    #====dev
    pkgs.direnv
    pkgs.fish
    pkgs.htop
    pkgs.jq
    pkgs.neovim # defaults to luajit
    pkgs.luajitPackages.luacheck

    #====rust
    pkgs.difftastic
    pkgs.du-dust
    pkgs.fd
    pkgs.helix
    pkgs.hyperfine
    pkgs.ripgrep
    pkgs.sd
    pkgs.stylua
    pkgs.tokei
    pkgs.watchexec
    pkgs.zellij
    pkgs.zoxide

    #====dev_lua
    pkgs.stylua
    pkgs.lua-language-server

    # pkgs.findutils
    # realpath?

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  nixpkgs.overlays = [
    #~/dotfiles/overlays/arcan.nix
    (final: prev: {
      __dontExport = true;
      arcanPackages = prev.arcanPackages.overrideScope' (finalScope: prevScope: {
        arcan = prevScope.arcan.overrideAttrs (finalAttrs: prevAttrs: {
          version = "581df5665a18432197662c569ed9a1bc60308461";
          src = final.fetchFromGitHub {
            owner = "letoram";
            repo = "arcan";
            rev = "581df5665a18432197662c569ed9a1bc60308461";
            hash = "sha256-XlJcp7H/8rnDxXzrf1m/hyYdpaz+nTqy/R6YHj7PGdQ=";
          };
          patches = [
            ~/dotfiles/patches/arcan-keyboard.patch
          ];
        });
      });
    })
  ];
  #nixpkgs.overlays = [
  #  (final: prev:
  #  {
  #    durden = prev.arcanPackages.durden.overrideAttrs (old: {
  #      patches = (old.patches or []) ++ [
  #        #  (prev.fetpatch {
  #        #   url = "";
  #        #   hash = "";
  #        # })
  #        #]
  #        #~/dotfiles/overlays/arcan-keyboard.nix
  #        ~/dotfiles/patches/arcan-keyboard.patch
  #      ];
  #    });
  #  }
  #  )
  #];

  #durden = pkgs.arcanPackages.durden.overrideAttrs (old: {
  #  patches = (old.patches or []) ++ [
  #    ~/dotfiles/patches/arcan-keyboard.patch
  #  ];
  #});

  # dotfiles
  home.file = {
    "./.config/" = {
        source = ~/dotfiles/.config;
        recursive = true;
    };
    "./.bashrc".source =  ~/dotfiles/.bashrc;
    "./.editorconfig".source =  ~/dotfiles/.editorconfig;
    "./.gitconfig".source =  ~/dotfiles/.gitconfig;
    # manage gnupg with home-manager instead

    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  # or
  #  /etc/profiles/per-user/jan/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = ["nix-command" "flakes"];
  };

  programs = {
    home-manager.enable = true;
    # Disable management of neovim plugins to prevent duplicated setup churn
    neovim.enable = false;
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
  # export GPG_TTY=$(tty)
  # set -gx GPG_TTY "$(tty)"
  services.gpg-agent = {
    defaultCacheTtl = 34560000;
    enable = true;
    enableScDaemon = false;
    enableSshSupport = true;
    maxCacheTtl = 34560000;
    pinentryFlavor = "tty";
  };
}
