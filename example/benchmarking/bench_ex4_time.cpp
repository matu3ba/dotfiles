// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex4_time.cpp -c -o ./build/bench_ex4_time.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex4_time.cpp -c -o ./build/bench_ex4_time.o
#include <algorithm>
#include <chrono>
#include <print>
namespace sc = std::chrono;

int main() {
  using clock = std::chrono::steady_clock;
  auto last = clock::now();
  // auto minDelta = std::numeric_limits<clock::duration>::max(); // UB uint->int conversion
  auto minDelta = 1'000'000'000; //ns
  for (int i = 0; i < 5'000; i += 1) {
    auto now = clock::now();
    auto delta = now - last;
    minDelta = std::min(minDelta, static_cast<int>(delta.count()));
    last = now;
  }
  std::print("Min={}\n", minDelta);
  // 20-30ns
}
