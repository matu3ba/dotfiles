// TODO make this more structured https://nullprogram.com/blog/2023/04/29/
// https://interrupt.memfault.com/blog/arm-cortexm-with-llvm-clang
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
-Wcast-align=strict \ // *char -> *u32 can be fine=>annoying
-fno-strict-aliasing \
// optimizations
-Wunsafe-loop-optimizations \
-Wvector-operation-performance
-fstrict-aliasing
// Profiling report:
// $ gcc -g -pg -o t t.c
// $ ./t 100 200
// $ gprof ./t | less
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
//

// Basic Hardening
// format
// -Wformat -Wformat-security -Werror=format-security
// stackprotector
// -fstack-protector-strong --param ssp-buffer-size=4
// fortify (block various buffer size things and replace unlimited length buffer fn calls with lenght limited ones)
// -O2 -D_FORTIFY_SOURCE=2
// pic (position independent code for ASLR)
// -fPIC
// make signed overflow defined (trapping)
// -fno-strict-overflow
// relro (relocate read only to make GOT read-only potentially breaking dynamic shared object loading)
// -z relro
// bindnow (resolve alldynamic symbols at program load to enable relro above)
// -z bindnow

// TODO explain and show how to check what is used for
// * -Wall
// * -Wextra
