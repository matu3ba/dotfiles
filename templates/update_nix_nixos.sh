#!/usr/bin/env sh

## Multi-user nix on Linux
nix-channel --update &&
  nix-env -iA nixpkgs.nix nixpkgs.cacert &&
  systemctl daemon-reload &&
  systemctl restart nix-daemon
# if above command fails
nix-channel --update && nix upgrade-nix

"$HOME"/.nix-channels shows the channel
nix --version
nix-channel --help

## NixOS
# disable the binary cache and build everything locally
nixos-rebuild switch --option binary-caches ''

# on changing channels use
nixos-rebuild --upgrade boot
# regular update without reboot
nixos-rebuild --upgrade switch
