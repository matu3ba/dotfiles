#!/usr/bin/env sh
# x86_64-linux CI script to clean cache, if necessary

# set -x
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

MAX_SIZE_B=2147483648 #2 GB = 2*(1024)**3 B
ZIG_CACHE_DIR="$(zig env | jq '. "global_cache_dir"')"
CHECK_SIZE_B=$(du -sb "$ZIG_CACHE_DIR" | cut -f1)
if test "$CHECK_SIZE_B" -ge $MAX_SIZE_B; then
  rm -fr "$ZIG_CACHE_DIR"
fi

zig env

zig build -Dno_opt_deps -Dno_cross test --summary all
