// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex9_clobber.cpp -c -o ./build/bench_ex9_clobber.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex9_clobber.cpp -c -o ./build/bench_ex9_clobber.o
#include <array>
#include <chrono>
namespace sc = std::chrono;
// List of things being clobbered is entire memory of computer
inline void ClobberMemory() { asm volatile("" : : : "memory"); }
// Input to assembly that compiler can not reason about is register or memory of expression value.
template<typename T> void DoNotOptimize(T const &value) { asm volatile("" : : "r,m"(value)); }
static std::array data{1, 2, 3, 4, 5};
static void benchmark_sum() {
  int total = 0;
  for (auto x : data)
    total += x;
  DoNotOptimize(total);
}

[[maybe_unused]]
static auto benchmark_sum_many() {
  auto now = sc::steady_clock::now();
  for (int i = 0; i < 16; i += 1) {
    ClobberMemory();
    benchmark_sum();
  }
  return sc::steady_clock::now() - now;
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
//"benchmark_sum_many()":
//  push rbx
//  call "std::chrono::_V2::steady_clock::now()"
//  mov edx, 16
//  mov rbx, rax
//.L2:
//  movdaq xmm0, XMMWORD PTR "data"[rip]
//  movdaq xmm1, xmm0
//  psrldq xmm1, 8
//  paddd xmm0, xmm1
//  movdqa xmm1, xmm0
//  psrldq xmm1, 4
//  paddd xmm0, xmm1
//  movd eax, xmm0
//  add eax, DWORD PTR "data"[rip+16]
//  sub edx, 1
//  jne .L2
//  call "std::chrono::_V2::steady_clock::now()"
//  sub rax, rbx
//  pop rbx
//  ret
//."data":
//  .long 1
//  .long 2
//  .long 3
//  .long 4
//  .long 5

// Standardization/std gap vs other languages.
