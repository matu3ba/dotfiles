#!/bin/sh
set -e
PATH="/usr/local/bin:$PATH"
trap 'rm -f "$$.tags"' EXIT
git ls-files | \
  ctags --tag-relative=yes -L - -f"$$.tags"
mv "$$.tags" "tags"
