#!/usr/bin/env sh
set -e
if test -z "$USER"; then
  # git bash
  cd "/c/Users/$USERNAME/Desktop"
  #grep 'ZIG_LLVM_CLANG_LLD_NAME =' /c/Users/$USERNAME/Desktop/zig/ci/x86_64-windows-debug.ps1 > /c/Users/$USERNAME/Desktop/pzdown.txt
else
  # WSL
  cd "/mnt/c/Users/$USER/Desktop"
  #grep 'ZIG_LLVM_CLANG_LLD_NAME =' /mnt/c/Users/$USER/Desktop/zig/ci/x86_64-windows-debug.ps1 > /mnt/c/Users/$USER/Desktop/pzdown.txt
fi
TARGET="x86_64-windows-gnu"
VERSION="0.11.0-dev.1869+df4cfc2ec"
ZIG_LLVM_CLANG_LLD_NAME="zig+llvm+lld+clang-$TARGET-$VERSION"
curl https://ziglang.org/deps/$ZIG_LLVM_CLANG_LLD_NAME.zip -o devkit.zip
# Windows does not check validity of symlinks
#unzip devkit.zip -d devkit

#!/usr/bin/env sh
# set -e
# cd /mnt/c/Users/$USER/Desktop
# ## start get VERSION
# cd zig
# # alternative: curl https://github.com/ziglang/zig/blob/master/ci/x86_64-windows.ps1
# raw_version=$(grep 'ZIG_LLVM_CLANG_LLD_NAME =' ci/x86_64-windows-debug.ps1 | cut -f3-4 -d"-")
# echo $raw_version
# len_version=$(echo -n $raw_version | wc -m)
# echo $len_version
# # cut " from string
# VERSION=$(echo $raw_version | cut --complement -c $len_version)
# echo $VERSION
# cd ..
# ## end get VERSION
# curl https://ziglang.org/deps/zig+llvm+lld+clang-x86_64-windows-gnu-$VERSION.zip -o devkit.zip
# unzip devkit.zip -d devkit
