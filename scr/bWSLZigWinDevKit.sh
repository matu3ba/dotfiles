#!/usr/bin/env bash

set -e
cd "/mnt/c/Users/$USER/Desktop"
## start get VERSION
cd zig
# alternative: curl https://github.com/ziglang/zig/blob/master/ci/x86_64-windows.ps1
raw_version=$(grep 'ZIG_LLVM_CLANG_LLD_NAME =' ci/x86_64-windows.ps1 | cut -f3-4 -d"-")
len_version=$(echo -n "$raw_version" | wc -m)
# cut " from string
VERSION=$(echo "$raw_version" | cut --complement -c "$len_version")
cd ..
## end get VERSION
DEVKIT=$(realpath devkit)/zig+llvm+lld+clang-x86_64-windows-gnu-$VERSION
ZIG=$DEVKIT/bin/zig.exe
TARGET=x86_64-windows-gnu
MCPU="baseline"

# use locally installed cmake, if existing
PATH="${HOME}/dev/git/cpp/cmake/build/bin/:${PATH}"

# zig cant handle WSL file paths:
# zig: error: no such file or directory: '/home/user/dev/git/cpp/cmake/Modules/CMakeCCompilerABI.c'
# cmake is unable to create the test files:
# zig: error: no such file or directory: '/mnt/c/Users/user/Desktop/zig/build/CMakeFiles/CMakeScratch/TryCompile-ZsCCCk/testCCompiler.c'
# zig: error: no input files
# => must use relative paths
# Due to "CMake does always use absolute paths." https://stackoverflow.com/a/45859872
# unusable unless
# 1. we can hack cmake to use relative paths
# 2. Zig somehow accepts unix paths on windows for build stuff
#
# idea:
# 1. look into hacking cmake
# 2. create windows batch script for getting version number
#
# general question:
# How should Zig support Windows / WSL?

cd zig
mkdir -p build
cd build

REL_DEVKIT=$(realpath --relative-to=. "$DEVKIT")
REL_ZIG=$(realpath --relative-to=. "$ZIG")

cmake .. -GNinja \
  -DCMAKE_INSTALL_PREFIX="stage3-release" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH="$REL_DEVKIT" \
  -DCMAKE_C_COMPILER="$REL_ZIG;cc;-target;$TARGET;-mcpu=$MCPU" \
  -DCMAKE_CXX_COMPILER="$REL_ZIG;c++;-target;$TARGET;-mcpu=$MCPU" \
  -DZIG_TARGET_TRIPLE="$TARGET" \
  -DZIG_TARGET_MCPU="$MCPU" \
  -DZIG_STATIC=ON \
  --debug-trycompile

# cmake .. -GNinja \
#   -DCMAKE_INSTALL_PREFIX="stage3-release" \
#   -DCMAKE_BUILD_TYPE=Debug \
#   -DCMAKE_PREFIX_PATH="$DEVKIT"  \
#   -DCMAKE_C_COMPILER="$ZIG;cc;-target;$TARGET;-mcpu=$MCPU" \
#   -DCMAKE_CXX_COMPILER="$ZIG;c++;-target;$TARGET;-mcpu=$MCPU" \
#   -DZIG_TARGET_TRIPLE="$TARGET" \
#   -DZIG_TARGET_MCPU="$MCPU" \
#   -DZIG_STATIC=ON \
#   --debug-trycompile

#ninja install
