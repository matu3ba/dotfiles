#!/usr/bin/env sh

# This installs every nix-related directory on the local system.
# However: This does not restore the /etc/shell backup!
# Restore and clean this up manually to prevent bashrc hiccups.

rm -rf ~/.nix-profile ~/.nix-defexpr ~/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels
sudo rm -rf /etc/profile/nix.sh /etc/nix /nix
# If you are on Linux with systemd, you will need to run:
sudo systemctl stop nix-daemon.socket
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket
sudo systemctl disable nix-daemon.service
sudo systemctl daemon-reload
