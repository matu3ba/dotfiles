// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex8_donotoptimize.cpp -c -o ./build/bench_ex8_donotoptimize.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex8_donotoptimize.cpp -c -o ./build/bench_ex8_donotoptimize.o
#include <array>
#include <chrono>
namespace sc = std::chrono;
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
  for (int i = 0; i < 16; i += 1)
    benchmark_sum();
  return sc::steady_clock::now() - now;
}
// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
//"benchmark_sum_many()":
//  push rbx
//  call "std::chrono::_V2::steady_clock::now()"
//  movdqa xmm0, XMMWORD PTR "data"[rip]
//  mov edx, 16
//  mov rbx, rax
//  movdaq xmm1, xmm0
//  psrldq xmm1, 8
//  paddd xmm0, xmm1
//  movdqa xmm1, xmm0
//  psrldq xmm1, 4
//  paddd xmm0, xmm1
//  movd eax, xmm0
//  add eax, DWORD PTR "data"[rip+16]
//.L2:
//  sub edx,
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

// Problem: Computation only done once, since compiler thinks value can not
// change on each iteration and just gives value in the end.
