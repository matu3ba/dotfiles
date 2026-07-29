#include <chrono>
#include <limits>
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
    minDelta = std::min(minDelta, delta);
    last = now;
  }
  std::print("Min={}\n", minDelta);
}
