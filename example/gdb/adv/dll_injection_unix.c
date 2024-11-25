///  4.3 dll injection unix
/// Tested with
/// TODO
/// https://stackoverflow.com/questions/24355344/inject-shared-library-into-a-process
/// Outside of the dynamic loader/linker with LD_PRELOAD, one needs to use
/// ptrace (for security):
/// - attach to process via ptrace
/// - stop all threads and children to make sure dlopen is safe to call, ie
/// before next entry to syscall (PTRACE_SYSEMU)
/// - continue with PTRACE_SYSCALL, PTRACE_SYSEMU until you are in process' code
/// via /proc/PID/maps
/// - get register state and peek program code to backup before replacing with
/// with dlopen call (PTRACE_GETREGS, PTRACE_PEEKTEXT, PTRACE_POKETEXT, dlopen
/// with RTLD_NOW)
/// - dont forget to have a syscall ending after dlopen to PTRACE_SYSCALL for it
/// - restore program with PTRACE_POKETEXT, PTRACE_SETREGS

// One can also do it manually, which becomes error-prone and slow:
// https://www.codeproject.com/Articles/33340/Code-Injection-into-Running-Linux-Application

// https://stackoverflow.com/a/24356162/9306292
// TODO: missing library usage/payload insertion, ie process_vm_writev memory to execute
#ifndef _GNU_SOURCE
#error "requires dynamic linking for loading adjusting via LD_PRELOAD"
#endif

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/ptrace.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  struct user_regs_struct oldregs, regs;
  unsigned long pid, addr, save[2];
  siginfo_t info;
  char dummy;

  if (argc != 3 || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
    fprintf(stderr, "\n");
    fprintf(stderr, "Usage: %s [ -h | --help ]\n", argv[0]);
    fprintf(stderr, "       %s PID ADDRESS\n", argv[0]);
    fprintf(stderr, "\n");
    return 1;
  }

  if (sscanf(argv[1], " %lu %c", &pid, &dummy) != 1 || pid < 1UL) {
    fprintf(stderr, "%s: Invalid process ID.\n", argv[1]);
    return 1;
  }

  if (sscanf(argv[2], " %lx %c", &addr, &dummy) != 1) {
    fprintf(stderr, "%s: Invalid address.\n", argv[2]);
    return 1;
  }
  if (addr & 7) {
    fprintf(stderr, "%s: Address is not a multiple of 8.\n", argv[2]);
    return 1;
  }

  /* Attach to the target process. */
  if (ptrace(PTRACE_ATTACH, (pid_t)pid, NULL, NULL)) {
    fprintf(stderr, "Cannot attach to process %lu: %s.\n", pid, strerror(errno));
    return 1;
  }

  /* Wait for attaching to complete. */
  waitid(P_PID, (pid_t)pid, &info, WSTOPPED);

  /* Get target process (main thread) register state. */
  if (ptrace(PTRACE_GETREGS, (pid_t)pid, NULL, &oldregs)) {
    fprintf(stderr, "Cannot get register state from process %lu: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Save the 16 bytes at the specified address in the target process. */
  save[0] = ptrace(PTRACE_PEEKTEXT, (pid_t)pid, (void *)(addr + 0UL), NULL);
  save[1] = ptrace(PTRACE_PEEKTEXT, (pid_t)pid, (void *)(addr + 8UL), NULL);

  /* Replace the 16 bytes with 'syscall' (0F 05), followed by the message string. */
  if (ptrace(PTRACE_POKETEXT, (pid_t)pid, (void *)(addr + 0UL), (void *)0x2c6f6c6c6548050fULL) ||
      ptrace(PTRACE_POKETEXT, (pid_t)pid, (void *)(addr + 8UL), (void *)0x0a21646c726f7720ULL)) {
    fprintf(stderr, "Cannot modify process %lu code: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Modify process registers, to execute the just inserted code. */
  regs = oldregs;
  regs.rip = addr;
  regs.rax = SYS_write;
  regs.rdi = STDERR_FILENO;
  regs.rsi = addr + 2UL;
  regs.rdx = 14; /* 14 bytes of message, no '\0' at end needed. */
  if (ptrace(PTRACE_SETREGS, (pid_t)pid, NULL, &regs)) {
    fprintf(stderr, "Cannot set register state from process %lu: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Do the syscall. */
  if (ptrace(PTRACE_SINGLESTEP, (pid_t)pid, NULL, NULL)) {
    fprintf(stderr, "Cannot execute injected code to process %lu: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Wait for the client to execute the syscall, and stop. */
  waitid(P_PID, (pid_t)pid, &info, WSTOPPED);

  /* Revert the 16 bytes we modified. */
  if (ptrace(PTRACE_POKETEXT, (pid_t)pid, (void *)(addr + 0UL), (void *)save[0]) ||
      ptrace(PTRACE_POKETEXT, (pid_t)pid, (void *)(addr + 8UL), (void *)save[1])) {
    fprintf(stderr, "Cannot revert process %lu code modifications: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Revert the registers, too, to the old state. */
  if (ptrace(PTRACE_SETREGS, (pid_t)pid, NULL, &oldregs)) {
    fprintf(stderr, "Cannot reset register state from process %lu: %s.\n", pid, strerror(errno));
    ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL);
    return 1;
  }

  /* Detach. */
  if (ptrace(PTRACE_DETACH, (pid_t)pid, NULL, NULL)) {
    fprintf(stderr, "Cannot detach from process %lu: %s.\n", pid, strerror(errno));
    return 1;
  }

  fprintf(stderr, "Done.\n");
  return 0;
}
