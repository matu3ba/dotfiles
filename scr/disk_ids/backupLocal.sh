#!/usr/bin/env sh
# shellcheck shell=sh
set -e

expect_eq() {
  test "$1" = "$2" || { echo "Got '$1', expected '$2'" >&2; exit 1; }
}

UUID="ac7f9689-c3ce-4e56-8cee-810ee3ca0d8b"
PATH_EXP="/run/media/${USER}/${UUID}"
PATH_ACT=$(findmnt -n -c -o TARGET --source UUID="$UUID")
expect_eq "$PATH_ACT" "$PATH_EXP"

rsync -a --info=progress2 --del "$HOME/" "$PATH_ACT/data/backupData/"
