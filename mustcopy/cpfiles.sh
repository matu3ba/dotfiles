#!/usr/bin/env sh
# cp files in this directory for installation

mkdir -p "${HOME}/.local/share/applications"
cp alazellij.desktop "${HOME}/.local/share/applications/alazellij.desktop"

update-desktop-database -v ~/.local/share/applications
