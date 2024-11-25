/*!  C89 compatible quirks and snippets */
#if 0
Tested with
zig cc -std=c89 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./templates/common_c89.c
zig cc -std=c89 -Werror -Weverything ./templates/common_c89.c
clang -std=c89 -Werror -Weverything templates/common_c89.c
msvc: cl.exe /Za templates/common_c89.c

SHENNANIGAN rounding direction for division with negative integers is implementation defined
SHENNANIGAN checking if c89 or c90 has no macro
- https://sourceforge.net/p/predef/wiki/Standards/ indicate there is no macro.
- https://gist.github.com/colematt/97a3b50b680cfff98456cdcdfe4c721c
- clang and gcc use c89, c90 and ansi flags identically.
#endif
/* These are c89 comments */

/* assert.h     assertions */
/* ctype.h      char types */
/* errno.h      system error numbers */
/* float.h      value ranges of floats */
/* limits.h     system limitations */
/* locale.h     locale settings */
/* math.h       math fns */
/* setjmp.h     advanced jump fns */
/* signal.h     signal handling */
/* stdarg.h     arg handling for variadic fns */
/* stddef.h     additional type definitions */
/* stdio.h      inputs and outputs */
/* stdlib.h     mixed standard fns like memory management */
/* string.h     string ops */
/* time.h       date and time */

/* C89 check macro */
#ifdef __STDC__
#ifdef __STDC_VERSION__
#if (__STDC_VERSION__ >= 199409L)
/* SHENNANIGAN: clangd complains about "not C89 compatible" even though __STDC_VERSION__ is undefined */
#error "not C89 compatible"
#endif
#endif
#else
#error "not C89 compatible"
#endif

#if 0
SHENNANIGANThere are no fixed typed integers.
So no inttypes.h and stdint.h
Missing pile of target dependent pointer sizes to reimplement stdint.h
Prefer typedefs, if possible.
#endif

/* only for x86_64 */
#ifdef __x86_64__
typedef short unsigned int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long uint64_t;
typedef unsigned long size_t;
typedef unsigned long uintptr_t;
#endif

#ifdef __aarch64__
typedef short unsigned int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;
typedef unsigned long size_t;
typedef unsigned long uintptr_t;
#endif

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void ptrtointtoptr(void);

static void memset_16aligned(void *ptr, char byte, size_t size_bytes, uint16_t alignment) {
  assert((size_bytes & (alignment - 1)) == 0);
  assert(((uintptr_t)ptr & (alignment - 1)) == 0);
  memset(ptr, byte, size_bytes);
}
void ptrtointtoptr(void) {
  uint16_t alignment = 16;
  uint16_t align_min_1 = alignment - 1;
  void *mem = malloc(1024 + align_min_1);
  void *ptr = (void *)((((uint64_t)mem) + align_min_1) & ~(uint64_t)align_min_1);
  printf("0x%lu, 0x%lu\n", (unsigned long)mem, (unsigned long)ptr);
  memset_16aligned(ptr, 0, 1024, alignment);
  free(mem);
}

/* Variadic macros alternative in C89 from
 * https://stackoverflow.com/questions/27663053/variadic-macros-alternative-in-ansi-c
 * */
#define LOG(args) (printf("[LOG]: %s:%d ", __FILE__, __LINE__), printf args)
#define PROMPT "[INFO] %s:%d "
#define FL __FILE__, __LINE__
#define DEBUG0(fmt) printf(PROMPT fmt, FL)
#define DEBUG1(fmt, a1) printf(PROMPT fmt, FL, a1)
#define DEBUG2(fmt, a1, a2) printf(PROMPT fmt, FL, a1, a2)
#define DEBUG3(fmt, a1, a2, a3) printf(PROMPT fmt, FL, a1, a2, a3)
static void missing_varargs_workaround(void) {
  int n = 42;
  LOG(("Hello, world\n"));
  LOG(("n = %d\n", n));
  DEBUG0("Hello, world\n");
  DEBUG1("Hello, %s\n", "world");
  DEBUG2("Hello, %s; %s\n", "world", "bye");
  DEBUG3("Hello, %s; %s, %s\n", "world", "bye", "world");
}

int main(void) {
  ptrtointtoptr();
  missing_varargs_workaround();

  return 0;
}
