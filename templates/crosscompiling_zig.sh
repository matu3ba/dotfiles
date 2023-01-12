# installing Zig + adding to PATH
# Linux

# Windows

export CC="$ZIG cc -fno-sanitize=all"
export CXX="$ZIG c++ -fno-sanitize=all"

export CC="$ZIG cc -fno-sanitize=all -s -target TAR -mcpu=MCPU"
export CXX="$ZIG c++ -fno-sanitize=all -s -target TAR -mcpu=MCPU"

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
