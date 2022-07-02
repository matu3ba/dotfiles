#!/bin/sh
# Minimal ctags generation
# https://github.com/ludovicchabant/vim-gutentags
# Stricter integration of ctags looks unreasonable due to autogen and configure usage
set -e
PATH="/usr/local/bin:$PATH"
trap 'rm -f "$$.tags"' EXIT
git ls-files | \
  ctags --tag-relative=yes -L - -f"$$.tags"
mv "$$.tags" "tags"
