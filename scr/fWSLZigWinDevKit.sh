#!/usr/bin/env sh
set -e
cd /mnt/c/Users/$USER/Desktop
## start get VERSION
cd zig
# alternative: curl https://github.com/ziglang/zig/blob/master/ci/x86_64-windows.ps1
raw_version=$(grep 'ZIG_LLVM_CLANG_LLD_NAME =' ci/x86_64-windows.ps1 | cut -f3-4 -d"-")
len_version=$(echo -n $raw_version | wc -m)
# cut " from string
VERSION=$(echo $raw_version | cut --complement -c $len_version)
cd ..
## end get VERSION
curl https://ziglang.org/deps/zig+llvm+lld+clang-x86_64-windows-gnu-$VERSION.zip -o devkit.zip
unzip devkit.zip -d devkit
