// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex7_asm.cpp -c -o ./build/bench_ex7_asm.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex7_asm.cpp -c -o ./build/bench_ex7_asm.o
// TODO show assembly
//==GCC inline asm syntax
// asm <optionally volatile> (
//   "template string %0, %1 .."
//   : outputs
//   : inputs
//   : clobbers
// );

// template string is compiler formatted string concatenated and send to assembler
// outputs, inputs, clobbers: list of symbols
// clobbers: destroys specific registers

//==constrains
//   "type" (expression)
//    types                 |  modifiers
// "r"          register    |= write only
// "m"          memory      |+ read/write
// "r,m"        reg or mem  |& early clobbers
// "i"          immediate   |
// "g"          anything    |
// "a", "b", .. specific reg|
// eg "=r" (dest), "+m" (buf)
// parenthesis expression is any C/C++ expression ending up with a value

#include <cstdint>
[[maybe_unused]]
static void test1() {
  uint64_t source = 1234;
  uint64_t dest;
  asm /*volatile*/ ("mov %1, %0"  // AT&T syntax (destination on right-hand side)
                    : "=r"(dest)  // outputs
                    : "r"(source) // inputs
                    :             // no clobbers
  );
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
// "test1()":
//   ret

#include <cstdint>
[[maybe_unused]]
static auto test2() {
  uint64_t source = 1234;
  uint64_t dest;
  asm /*volatile*/ ("mov %1, %0"  // AT&T syntax (destination on right-hand side)
                    : "=r"(dest)  // outputs
                    : "r"(source) // inputs
                    :             // no clobbers
  );
  return dest;
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
// "test2()":
//   mov eax, 1234
//   mov rax, rax
//   ret

// GCC's optimizers discords asm statements if there is no need for the output vars.
// Optizmiers may move code out of loops if code always returns same result.
// Using volatile disables these optimizations.
#include <cstdint>
[[maybe_unused]]
static auto test3() {
  uint64_t source = 1234;
  uint64_t dest;
  asm volatile("mov %1, %0"  // AT&T syntax (destination on right-hand side)
               : "=r"(dest)  // outputs
               : "r"(source) // inputs
               :             // no clobbers
  );
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
// "test3()":
//   mov eax, 1234
//   mov rax, rax
//   ret

// Prvent optimizations. Look at for example Google bench for more tricks.
template<typename T> void DoNotOptimize(T const &value) {
  asm volatile(""             // no instruction at all
               :              // no outputs
               : "r,m"(value) // input (memory given by register or memory locations)
               :              // no clobbers
  );
}
