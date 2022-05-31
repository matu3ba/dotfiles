https://interrupt.memfault.com/blog/arm-cortexm-with-llvm-clang
clang usage:
$make clean && CLI_CFLAG_OVERRIDES="-Weverything -Wno-error" \
  COMPILER=clang make &> compilation_results.txt
$grep -o "\[\-W.*\].*" compilation_results.txt | sort -u

-g -Wall -Wextra -Werror \
-Wpedantic -pedantic-errors \
-Wconversion -Wconversion-extra -Wdouble-promotion \
-Wsuggest-attribute={pure,const,noreturn,malloc,cold} \
-Wmissing-format-attribute \
// code style
-Wshadow -Wstrict-prototypes -Wmissing-prototypes \
-Wunreachable-code -Wredundant-decls \
-Wunused -Wunused-parameter -Wvariadic-macros \
-Wuseless-cast -Walloca \
// safety
-Wstack-usage=8388608 \
-Warray-bounds -Wpacked \
-Wpointer-arith \
-Wnormalized -Wlogical-op
-Wnon-virtual-dtor
-Wsuggest-final-methods -Wsuggest-final-types
-Wsuggest-override \
-ftrapv \
-Wcast-align \ // *char -> *u32 can be fine=>annoying
// optimizations
-Wunsafe-loop-optimizations \
-Wvector-operation-performance

// less frequently used
-Wuninitialized -Winit-self
-D_FORTIFY_SOURCE=2
-Wfloat-equal
-std=c17
// ptr cast
-Wcast-qual
-Weverything: // -Wcast-align *char -> *u32 can be fine=>annoying
-Wsuggest-attribute={pure,const,noreturn,format,cold,malloc}

// redundant: -Wstrict-aliasing=1
// annoyances by -Wall: -Wmissing-braces is relative useless
// ideal solution: clang -g -std=c17 -Weverything *.c -o binary
// + use sanitizer?
