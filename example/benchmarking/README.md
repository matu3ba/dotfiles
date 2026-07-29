https://www.youtube.com/watch?v=EU_nQh8wg5A
"benchmarking: its about time" by matt godbolt

what can go wrong?
==clocks
==compilers
==CPUs
==confounding_factors

```
zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex1.cpp -o ./build/bench_ex1.exe && ./build/bench_ex1.exe
zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex1.cpp -o ./build/bench_ex1.exe && ./build/bench_ex1.exe
```

std::chrono clocks
```
struct some_clock {
  using rep = ..;
  using period = ..;
  using duration = duration<rep, period>;
  using time_point = time_point<some_clock>;
  static constexpr bool is_steady = ..;
  static time_point now() noexcept {
    ..
  }
```

system_clock: wall time
steady_clock: monotonic time
high_resolution_clock_clock: steady_clock in a trench

godbolt compiler explorer
#include<chrono>
namespace sc = std::chrono;
auto get_time() {
  return sc::steady_clock::now();
}
-O2 -std=c++23 -Wall -Wextra -Wsign-conversion -Werror -static

bench_ex3_vdso code:
shared memory, sequence lock
mult, shift, cycle_laste updated on tick
MONOTONIC: mult steered by NTP
MONOTONIC_RAW: mult fixed at boot

whole process:
1 sc::steady_clock::now();
2 __clock_gettime(CLOCK_MONOTONIC)
3 vDSO (no syscall)
4 seq lock { rdtsc + calibration maths }
5 struct timespec
6 time_point{timespec to nanos}

TODO finish talk
