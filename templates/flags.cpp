// Everything
// clang++ -std=c++14 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage .\templates\common.cpp
// clang++ -std=c++17 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage .\templates\common.cpp
// clang++ -std=c++20 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage .\templates\common.cpp
// clang++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage .\templates\common.cpp
// clang++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage .\templates\common.cpp
// -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage

// Fast
// -verify -fsyntax-only

-g -O -Wall -Weffc++ -pedantic  \
-pedantic-errors -Wextra -Waggregate-return \
-Wcast-qual  -Wchar-subscripts  -Wcomment -Wconversion \
-Wdisabled-optimization \
-Werror -Wfloat-equal  -Wformat  -Wformat=2 \
-Wformat-nonliteral -Wformat-security  \
-Wformat-y2k \
-Wimplicit  -Winit-self  -Winline \
-Winvalid-pch   \
-Wunsafe-loop-optimizations  -Wlong-long -Wmissing-braces \
-Wmissing-field-initializers -Wmissing-format-attribute   \
-Wmissing-include-dirs -Wmissing-noreturn \
-Wpacked  -Wpadded -Wparentheses  -Wpointer-arith \
-Wredundant-decls -Wreturn-type \
-Wsequence-point  -Wshadow -Wsign-compare  -Wstack-protector \
-Wstrict-aliasing -Wstrict-aliasing=2 -Wswitch  -Wswitch-default \
-Wswitch-enum -Wtrigraphs  -Wuninitialized \
-Wunknown-pragmas  -Wunreachable-code -Wunused \
-Wunused-function  -Wunused-label  -Wunused-parameter \
-Wunused-value  -Wunused-variable  -Wvariadic-macros \
-Wvolatile-register-var  -Wwrite-strings
-Wcast-align

-std=c++20 -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables
-Ithird-party/xxhash -DMOLD_VERSION=\"1.1.1\" -DLIBDIR="\"/usr/local/lib\""
-DGIT_HASH=\"3768ca612e794c5c391f115b741229318070e73f\"
-Ithird-party/mimalloc/include
-Ithird-party/tbb/include
-MT out/elf/arch-ar
m32.o -MMD -MP -MF out/elf/arch-arm32.d
-O2 -c -o out/elf/arch-arm32.o elf/arch-arm32.cc

-Wnon-virtual-dtor
