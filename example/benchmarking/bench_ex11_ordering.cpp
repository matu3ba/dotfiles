// zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex11_ordering.cpp -c -o ./build/bench_ex11_ordering.o
// zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-switch-default ./example/benchmarking/bench_ex11_ordering.cpp -c -o ./build/bench_ex11_ordering.o
//==ordering
// modern CPUs dont run in order
// instructions run as soon as ready
// "as-if" in microcode

// rdtsc: immediate
// rdtscp: after prior instrs completed (but followup instrs may still run earlier)

//==assembly from intel manual on fencing
// lfence ; ensure all loads complete
// rdtsc  ; read time
//
// ; code under test here
//
// rdtscp ; rdtsc but partially serializing
// lfence ; ensure nothing beyond migrates above

//==c++ code for fencing
#include <cstdint>
[[maybe_unused]]
static auto test() {
  __builtin_ia32_lfence();
  auto const start = __builtin_ia32_rdtsc();
  // ..
  std::uint32_t aux;
  auto const end = __builtin_ia32_rdtscp(&aux);
  __builtin_ia32_lfence();
  return end - start;
}

//==bench results
// cost of 3 idivs?
// rdtsc           ~11 ns
// rdtscp          ~187 ns
// lfence;rdtsc..  ~159 ns
// rdtscp;lfence
// probably only matters for microbenchmarks

//==clock_gettime does what?
//..
//  and r10d, 0x1
//  jne _seqlockFial
//  mov eax, [r11,0x4]
//  cmp eax, 0x1
//  jne _notTsc
//  rdtscp   ; rdtscp but no fences in sight!
//  xchg ax, ax
//  shl rdx, 0x20
//  or rdx, rax
//  btr rdx, 0x3f
//  movsxd r8, edi

//==cost of asking time
// method               ns cycles instr IPC (instr per cycles)
// rdtsc                14 27     10    0.36
// rdtscp               23 43     11    0.25
// steady_clock::now()  35 68     100   1.46
// => ~25 cycles vDSO overhead, ~89 more instructions?

//==account for clock overhead
// 1 subtract overhead
// 2 amortise over N runs
// 3 cancel overhead (cycle bench)
