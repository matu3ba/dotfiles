#!/bin/sh
# Use cases: embedded/constrained device
# downloading and crosscompiling entrl with libclang:
# See https://clang.llvm.org/docs/CrossCompilation.html
# armv7l-linux-gnu
# ./configure
# CC='zig cc armv7l-linux-gnu' make

while $(true); do
  # -d: track dirs and exit if new file added
  # -n non interactive mode
  # -r reload persistent child (wait for child process to finish)
  echo ./my_watch_dir | entr -dnr 'ls ./my_watch_dir'
done;
