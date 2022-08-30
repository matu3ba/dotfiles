export CC="$ZIG cc -fno-sanitize=all"
export CXX="$ZIG c++ -fno-sanitize=all"

export CC="$ZIG cc -fno-sanitize=all -s -target TAR -mcpu=MCPU"
export CXX="$ZIG c++ -fno-sanitize=all -s -target TAR -mcpu=MCPU"

# often configuration problems for "unknown c compiler"
