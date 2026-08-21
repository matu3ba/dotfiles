//zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex1.cpp -c -o ./build/bench_ex1.o
//zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex1.cpp -c -o ./build/bench_ex1.o
#include <array>
#include <chrono>
#include <print>
#include <span>
namespace sc = std::chrono;

static int sum(std::span<int const> const v) {
  int total = 0;
  for (auto x : v)
    total += x;
  return total;
}

int main() {
  constexpr std::array data{1, 2, 3, 4, 5};
  auto const start = sc::system_clock::now();
  auto result = sum(data);
  auto const end = sc::system_clock::now();
  std::print("result={}, took {}\n", result, end - start);
}
