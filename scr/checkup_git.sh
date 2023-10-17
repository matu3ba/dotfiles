#!/usr/bin/env bash

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

cd "$HOME/dev/git/c/firejail/"
git fetch
if test "$(git rev-parse HEAD)" = "$(git rev-parse @{u})"; then
  echo "firejail: HEAD and upstream identical"
else
  echo "firejail: HEAD and upstream different"
  # git merge --ff-only upstream/master && ./configure && ${HOME}/dev/git/cpp/mold/build/mold -run make && sudo make install-strip && sudo firecfg
  git merge --ff-only upstream/master && CC="zig cc -fno-sanitize=all" ./configure && make && sudo make install-strip && sudo firecfg
fi

# hack for runnig zig compiler on document
# ///usr/bin/env -S zig run

# 2. Build zig compiler, if needed
cd "${HOME}/dev/git/zi/zig/master"
# 2.1 exist changes? => exit
#if output=$(git status --porcelain) && test -z "$output"; then
#  echo "zig: Working directory clean"
#else
#  echo "zig: Uncommitted changes, exiting.."
#  exit
#  #git stash --include-untracked
#fi
# 2.2 other branch than master? => exit
#if output=$(git symbolic-ref --short -q HEAD) && test "$output" = "master"; then
#  echo "zig: branch is master"
#else
#  echo "zig: branch not master, exiting.."
#  exit
#fi
# 2.3 if no updates exist => exit
git fetch
if test "$(git rev-parse HEAD)" = "$(git rev-parse @{u})"; then
  echo "zig: HEAD and upstream identical"
else
  echo "zig: HEAD and upstream different"
  git merge --ff-only upstream/master
  ## stage3 only (no stage1) ##
  #echo "zig: building stage3 with stage3"
  #/usr/bin/time -v "${HOME}/dev/git/bootstrap/zig-bootstrap/musl/out/zig-x86_64-linux-musl-native/bin/zig" build -p build/stage3 --search-prefix "${HOME}/dev/git/bootstrap/zig-bootstrap/musl/out/x86_64-linux-musl-native" --zig-lib-dir lib -Dstatic-llvm
  # echo "zig: building stage1,2,3.."
  mkdir -p build/ && cd build/ && cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/host/" -GNinja && /usr/bin/time -v ninja install  && cd .. &
  mkdir -p buildrel/ && cd buildrel/ && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$HOME/dev/git/bootstrap/zig-bootstrap/musl/out/host/" -GNinja && /usr/bin/time -v ninja install && cd ..
  #-DCMAKE_PREFIX_PATH="$HOME/dev/git/bootstrap/zig-bootstrap/glibc/out/host/"
fi
