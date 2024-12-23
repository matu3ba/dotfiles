#!/usr/bin/env sh
# aarch64-macos CI script to clean cache, if necessary

# set -x
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

MAX_SIZE_B=2097152 #2 GB = 2*(1024)**2 KB
ZIG_CACHE_DIR="$(zig env | jq '. "global_cache_dir"')"
if test -e "$ZIG_CACHE_DIR"; then
  CHECK_SIZE_B=$(du -ks "$ZIG_CACHE_DIR" | cut -f1)
  if test "$CHECK_SIZE_B" -ge $MAX_SIZE_B; then
    echo "$CHECK_SIZE_B > $MAX_SIZE_B, removing global zig cache dir.."
    rm -fr "$ZIG_CACHE_DIR"
  fi
fi

zig env

zig build -Dno_opt_deps -Dno_cross test --summary all
