#include <chrono>
namespace sc = std::chrono;

// glibc/sysdeps/unix/clock_gettime.c
// int clock_gettime(clockid_t clk_id, timespec *tp) {
//   switch(clk_id) {
//     case CLOCK_MONOTONIC: [[fallthrough]
//     case CLOCK_REALTIME:
//       return INLINE_VSYSCALL(clock_gettime, clk_id, tp);
//   }
// }

// int (*__vdso_clock_gettime)(int, timeval *);

// inline int inline_vsyscall_clock_gettime(
//   clockid_t clk_id, timespec *tp) {
//   if (__vdso_clock_gettime) {
//     return __vdso_clock_gettime(clk_id, tp);
//   }
//   return syscall(clock_gettime, sc_err, 2, clk_id, tp);
// }

// vDSO as virtualized Dynamic Shared Object provided by kernel
// gdb /bin/true
// (gdb) starti
// starting program /usr/bin/true
// (gdb) disassemble __vdso_clock_gettime
//   0x00007fffff7bd1e0 <+9>:    jmp     0x7fffff7fbcd930
// (gdb) 0x7fffff7fbcd930,+0x400
//   0x7fffff7fbcd930: push %dbp
//   0x7fffff7fbcd931: mov  %rsp,%rbp
//   0x7fffff7fbcd934: push %r14
//   ..

int main() {
  using clock = std::chrono::steady_clock;
  for (int i = 0; i < 1'000'000; i += 1)
    clock::now();
}

// >g++ clock.cpp
// >strace ./a.cout 2>&1 | grep -iE 'clock|time'
// >[empty]
