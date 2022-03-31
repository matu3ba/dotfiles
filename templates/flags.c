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
-Warray-bounds -Wcast-align -Wpacked \
-Wpointer-arith \
-Wnormalized -Wlogical-op
-Wnon-virtual-dtor
-Wsuggest-final-methods -Wsuggest-final-types
-Wsuggest-override \
-ftrapv \
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
-Weverything
-Wsuggest-attribute={pure,const,noreturn,format,cold,malloc}

// redundant: -Wstrict-aliasing=1
// annoyances by -Wall: -Wmissing-braces is relative useless
// ideal solution: clang -g -std=c17 -Weverything *.c -o binary
// + use sanitizer?
