#!/usr/bin/env sh

# installing Zig + adding to PATH
# Linux

# Windows

export CC="$ZIG cc -fno-sanitize=all"
export CXX="$ZIG c++ -fno-sanitize=all"

export CC="$ZIG cc -fno-sanitize=all -s -target TAR -mcpu=MCPU"
export CXX="$ZIG c++ -fno-sanitize=all -s -target TAR -mcpu=MCPU"

# cmake -DCMAKE_BUILD_TYPE=Release \
# -DCMAKE_ASM_COMPILER='zig;cc;-fno-sanitize=all;-s' \
# -DCMAKE_C_COMPILER='zig;cc;-fno-sanitize=all;-s' \
# -DCMAKE_CXX_COMPILER='zig;c++;-fno-sanitize=all;-s' -B build

# 1. With the zcc.sh and zcpp.sh in PATH to workaround spaces not being respected
CC="zcc.sh" CXX="zcpp.sh" cmake -GNinja ../
# 2. Using CMake CC compiler flags:
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CC_COMPILER='zcc.sh' -DCMAKE_CXX_COMPILER='zcpp.sh' -GNinja ..
# 3. newer cmake versions support ; as separator for space
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER='zig;cc' -DCMAKE_CXX_COMPILER='zig;c++' -GNinja ..
# 4. using cmake build system invocation to work with multiple build systems
cmake --build . -j "$(nproc)"
# 5. even newer cmake supports relative build dir from root dir
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER='zig;cc' -DCMAKE_CXX_COMPILER='zig;c++' -B build
cmake --build build -j "$(nproc)"

# often configuration problems for "unknown c compiler"

# to use zig as crosscompiler
CC='zig cc' ./configure
make "-j$(nproc)"

# to get compile_commands.json, compile once with gcc
make distclean
./configure
bear -- make "-j$(nproc)"
make distclean
CC='zig cc' ./configure
make "-j$(nproc)"

# Note: bear is picky to handle other compilers and clangd will likely complain
# about unknown compiler
