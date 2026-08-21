// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex14_branching.cpp -c -o ./build/bench_ex14_branching.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex14_branching.cpp -c -o ./build/bench_ex14_branching.o
#include <vector>
[[maybe_unused]]
static int state_machine(std::vector<int> const &data, int threshold) {
  int state = 0, acc = 0;
  for (auto v : data) {
    if (state == 0) {
      if (v > threshold) {
        acc += v * v;
        state = 1;
      } else {
        acc += v;
      }
    } else {
      if (v & 1) {
        acc ^= v;
        state = 0;
      } else {
        acc += v >> 2;
      }
    }
  }
  return acc;
}
// auto benchmark(size_t datSize, size_t N) {
//   // seeded random data
//   auto data = make_data(dataSize);
//   auto start = now();
//   for (size_t repeat = 0; repeat < N; repeat += 1) {
//     DoNotOptimizeAway(statemachine(data, 50));
//   }
//   auto end = now();
//   return end - start;
// }

// .benchmark.tsc_fenced state_machine_256
// # samples: 150  (+10 warum, discarded)
// name                 min
// state_machine_256    0.59ns/elem

// different machines, different perf
// ie comet lake, lunar lake, AMD EPYC

// perf state -e cycles,instructions,branches,branch-miss taskset -c 2 ./benchmark.tsc_fenced state_machine_4096
// NUMBER cyclces
// NUMBER instructions # 2.65 insn per cycle
// NUMBER branches
// NUMBER branch-misses # 0.44% of all branches
//dataSize instructions branches miss   IPC
//1,024    1.35B        420M     0.02%  3.22
//4,096    1.35B        420M     0.44%  2.54
//8,192    1.35B        419M     8.67%  0.96
//32,768   1.35B        421M     18.19% 0.59

//==branching
// * is this real?
// * what do we want to measure?

//==And..
// OoO overlap
// latency vs throughput
// cache & memory

//==Pertubations
// scheduler, irqs
// frequency scaling, boost, thermals
// ASLR, link order, env (compiler etc)
// noisy neighbours
// system load..

//==Approaches
// * embrace it
// * minimise it

//==System noise mitigations
// # pin and isolate
// taskset -c 3 ./bench
// # at boot: isolcpus=3 nohz_full=3 rc-nobs=3
//
// #frequency
// sudo cpupower frequency-set -g performance
// echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
//
// # IRQs off your core
// echo fffffff7 | sudo tee /proc/irq/*/smp_affinity

//==Noise only makes things slower.
//==Averages is very useless.

//==Which question?
// * best case
// * typical
// * bounded worst case

//==Sensitivity
// BPU-heavy?
// * mix up branch predictor
// * duplicating code blocks to run it in different
// cache-relient?
// * flushing cache etc
// scheduler-jitter
// perf & CDF shape
// icache stuff etc
// systemtap
// ebpf
// etc

// finance: book of order to back of queue and front of queue (push cheap, pop not etc)
// arbitrary canceling (right in middle): O(N) algorithm, so N users doing it means O(N^2)
// slow but steady might be best ie linked list

// real workloads
// benchmark says faster
// app says no difference

// in-situ stats
//
// benchmarking vs profiling
// benchmarking how fast?
// profile: why that fast?
// * Intel processes: can stream out where CPU is cycle by cycle
//   - can later on
// * magic trace can do this too

// perf
// * stat     - counters
// * record   - sample profiler
// * report   - interactive view
// * annotate - per instrn
// * top      - live profile
// * list     - what counters exist?
// perf list | wc -l => 7,1k events

// tools
// google benchmark/catch2 (dont write your own unless you know why)
// * statistical analysis during running etc
// tracy - pipeline timing
// * frame by frame thing for games
// valgrind/callgrind - exact but slow
// * CPU simulator for cache effects
// perf-cpp - wrapper for perf_event_open
// uiCA/uops.info - low level info

// If an single optimisation makes routine 2 or more times faster,
// then you've broken the code.
// Unless it's a algo change.

// Problems
// * compiler: can eliminate work
// * cpu: predicts overlaps work
// * caches can make data unrealistically fast
// * os can interrupt measurement
// * clock itself has overhead

// Solutions
// * compiler limits, workaround them
// * clock choice + tradeoff
// * cpu suprises (BPU, OoO, cache)
// * know your sensitivity
// * distribution: fastest? bounded?
// * tools: catch2, gbench, in-situ
