#!/usr/bin/env sh

nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs

nix-env -iA nixpkgs.nixUnstable
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

#TODO look into https://www.yanboyang.com/nixhomemanager/
