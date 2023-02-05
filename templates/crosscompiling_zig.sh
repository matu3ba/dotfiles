# installing Zig + adding to PATH
# Linux

# Windows

export CC="$ZIG cc -fno-sanitize=all"
export CXX="$ZIG c++ -fno-sanitize=all"

export CC="$ZIG cc -fno-sanitize=all -s -target TAR -mcpu=MCPU"
export CXX="$ZIG c++ -fno-sanitize=all -s -target TAR -mcpu=MCPU"

# with the zcc.sh and zcpp.sh in PATH to workaround spaces not being respected
CC="zcc.sh" CXX="zcpp.sh" cmake -GNinja ../
# newer cmake versions support an explicit flag:
cmake -DCMAKE_C_COMPILER=="zig cc" -DCMAKE_CXX_COMPILER="zig cc" -GNinja ../

# often configuration problems for "unknown c compiler"

# to use zig as crosscompiler
CC='zig cc' ./configure
make -j$(nproc)

# to get compile_commands.json, compile once with gcc
make distclean
./configure
bear -- make -j$(nproc)
make distclean
CC='zig cc' ./configure
make -j$(nproc)

# Note: bear is picky to handle other compilers and clangd will likely complain
# about unknown compiler
