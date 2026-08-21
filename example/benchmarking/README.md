https://www.youtube.com/watch?v=EU_nQh8wg5A
"benchmarking: its about time" by matt godbolt

assembly followup by https://lobste.rs/s/wphnca/everyone_says_assembly_is_untyped
https://www.gingerbill.org/article/2026/08/20/designing-odins-inline-asm/
* The advantage/disadvantage of intrinsics is that they don't expose register
  allocation. The compiler is free to reorder them where it can prove the
  reordering is equivalent and to insert stack spills and reloads as needed in
  the middle.
* The advantage/disadvantage of intrinsics is that they permit optimizations. The compiler
  can constant-fold them, optimize shuffles for the target architecture, etc.;
  Clang/LLVM does this.

what can go wrong?
==clocks
==compilers
==CPUs
==confounding_factors

```
example/benchmarking/bench_ex1.cpp
example/benchmarking/bench_ex2_now.asm
example/benchmarking/bench_ex3.cpp
example/benchmarking/bench_ex3_vdso.asm
example/benchmarking/bench_ex4_time.cpp
example/benchmarking/bench_ex5_bench.cpp
example/benchmarking/bench_ex6_volatile.cpp
example/benchmarking/bench_ex7_asm.cpp
example/benchmarking/bench_ex8_donotoptimize.cpp
example/benchmarking/bench_ex9_clobber.cpp
example/benchmarking/bench_ex10_counters.cpp
example/benchmarking/bench_ex11_ordering.cpp
example/benchmarking/bench_ex12_cyclebench.cpp
example/benchmarking/bench_ex13_clock_selection.cpp
example/benchmarking/bench_ex14_branching.cpp
example/benchmarking/bench_ex15_summary.cpp
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
