//! Replacements applied to ld_preload.c
//! Stolen from https://www.themetabytes.com/2017/11/25/ld_preload-hacks/
// Tested with

#ifdef USAGE
#include <stdio.h>

#if USAGE == 1
//==1_simple
int rand() {
  printf("so random!\n");
  return 42;
}
#elif USAGE == 2
//==2_advanced
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdarg.h>

typedef int (*orig_printf_f_type)(char const *format, ...);
typedef int (*orig_vprintf_f_type)(char const *format, va_list arglist);

int printf(char const *format, ...) {
  va_list args;
  va_start(args, format);
  orig_printf_f_type orig_printf = (orig_printf_f_type)dlsym(RTLD_NEXT, "printf");
  orig_vprintf_f_type orig_vprintf = (orig_vprintf_f_type)dlsym(RTLD_NEXT, "vprintf");

  orig_printf("Something evil..!\n");

  int n = orig_vprintf(format, args);
  va_end(args);
  return n;
}
#elif USAGE == 3
#include <dlfcn.h>
#include <execinfo.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void handler(int sig) {
  printf("Error: signal %d:\n", sig);
  printf("I can do whatever I want in here!\n");
  exit(1);
}
void _init(void) {
  printf("Loading hack.\n");
  signal(SIGSEGV, handler);
}
#endif
#endif
