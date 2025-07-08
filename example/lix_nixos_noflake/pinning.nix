{ config, pkgs, ... }:
let sources = import ./npins;
in {
  # We need the flakes experimental feature to do the NIX_PATH thing cleanly
  # below. Given that this is literally the default config for flake-based
  # NixOS installations in the upcoming NixOS 24.05, future Nix/Lix releases
  # will not get away with breaking it.
  # nix.settings = {
  #   experimental-features = "nix-command flakes";
  # };

  # FIXME(24.05 or nixos-unstable): change following two rules to
  #
  # nixpkgs.flake.source = sources.nixpkgs;
  #
  # which does the exact same thing, using the same machinery as flake configs
  # do as of 24.05.
  # nix.registry.nixpkgs.to = {
  #   type = "path";
  #   path = sources.nixpkgs;
  # };
  # nix.nixPath = ["nixpkgs=flake:nixpkgs"];

  nixpkgs.flake.source = sources.nixpkgs;
}
