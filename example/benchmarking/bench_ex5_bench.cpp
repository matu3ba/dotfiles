// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex5_bench.cpp -c -o ./build/bench_ex5_bench.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex5_bench.cpp -c -o ./build/bench_ex5_bench.o
#include <array>
#include <chrono>
#include <span>
namespace sc = std::chrono;

constexpr std::array data{1, 2, 3, 4, 5};
static int sum(std::span<int const> v) {
  int total = 0;
  for (auto x : v)
    total += x;
  return total;
}
[[maybe_unused]] static auto benchmark() {
  auto start = sc::steady_clock::now();
  [[maybe_unused]] int result = sum(data);
  return sc::steady_clock::now() - start;
}

// -O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror
// "benchmark()":
//   push rbx
//   call "std::chrono::_V2::steady_clock::now()"
//   mov rbx, rax
//   call "std::chrono::_V2::steady_clock::now()"
//   sub rax, rbx
//   pop rbx
//   ret
