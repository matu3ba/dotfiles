// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex10_counters.cpp -c -o ./build/bench_ex10_counters.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex10_counters.cpp -c -o ./build/bench_ex10_counters.o
//==hw counters
// time-stamp count rdtsc, rdtscp
// stable since pentium 4
// invariant since nehalem (phenom for amd)
//   ARM has CNTVCT_EL0

// rdtsc: immediate
// rdtscp: after prior instrs completed (but followup instrs may still run earlier)

// rdtsc: read counter into edx:eax

#include <cstdint>
[[maybe_unused]]
static uint64_t now1() {
  uint32_t lo, hi;
  asm("rdtsc"
      : "=a"(lo), "=d"(hi) // outputs going into a (rax) and d (rdx) register
      :                    // inputs
      :                    // clobbers
  );
  return static_cast<uint64_t>(lo) | (static_cast<uint64_t>(hi) << 32);
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
//"now1()":
//  rdtsc
//  sal rdx, 32
//  mov eax, eax
//  or rax, rdx
//  ret
//Problem: mov is superflously done, because we shift by 32 bits and use 32 bit variables.
// Thus compiler clears top bits via moving 64-bit register to itself via mov eax, eax
//Solution: Use 64 bit values instead.
#include <cstdint>
[[maybe_unused]]
static uint64_t now2() {
  uint64_t lo, hi;
  asm("rdtsc"
      : "=a"(lo), "=d"(hi) // outputs going into a (rax) and d (rdx) register
      :                    // inputs
      :                    // clobbers
  );
  return lo | (hi << 32);
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
//"now2()":
//  rdtsc
//  sal rdx, 32
//  mov eax, eax
//  or rax, rdx
//  ret

// Problem: clang may optimize away now()
// Solution: use asm volatile instead.
#include <cstdint>
[[maybe_unused]]
static uint64_t now3() {
  uint64_t lo, hi;
  asm volatile("rdtsc"
               : "=a"(lo), "=d"(hi) // outputs going into a (rax) and d (rdx) register
               :                    // inputs
               :                    // clobbers
  );
  return lo | (hi << 32);
}

// with proper formatting
#include <cstdint>
[[maybe_unused]]
static uint64_t now4() {
  uint64_t lo, hi;
  asm volatile("rdtsc" : "=a"(lo), "=d"(hi));
  return lo | (hi << 32);
}
// best to use intrinsics instead
[[maybe_unused]]
static uint64_t now5() {
  return __builtin_ia32_rdtsc();
}
