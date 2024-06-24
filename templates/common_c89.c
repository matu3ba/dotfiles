/*!  C89 compatible quirks and snippets */
/* These are c89 comments */
/* This is how to uncomment sections containing code reliably: #if 0 */

/* SHENNANIGAN rounding direction for division with negative integers is implementation defined */

/* clang -std=c89 -Weverything file.c */
/* msvc: cl.exe /Za file.c */

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

/* SHENNANIGAN checking if c89 or c90 has no macro */
/* - unclear, if necessary */
/* - https://gist.github.com/colematt/97a3b50b680cfff98456cdcdfe4c721c  */
/* - https://sourceforge.net/p/predef/wiki/Standards/ indicate there is no macro. */
/* - clang and gcc use c89, c90 and ansi flags identically. */

#if defined(__STDC__)
#define IS_MAYBE_C89
  #if defined(__STDC_VERSION__)
    #if (__STDC_VERSION__ >= 199409L)
      #define IS_NOT_C89
    #endif
  #endif
#endif

#ifndef IS_MAYBE_C89
  #error "not C89 compatible"
#endif
#ifdef IS_NOT_C89
  #error "not C89 compatible"
#endif

/* SHENNANIGAN There are no fixed typed integers. */
/* So no inttypes.h and stdint.h */
/* Missing pile of target dependent pointer sizes to reimplement stdint.h */
/* Prefer typedefs, if possible */

/* only for x86_64 */
typedef short unsigned int uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long uint64_t;
typedef unsigned long size_t;
typedef unsigned long uintptr_t;

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void ptrtointtoptr(void);

static void memset_16aligned(void * ptr, char byte, size_t size_bytes, uint16_t alignment) {
    assert((size_bytes & (alignment-1)) == 0);
    assert(((uintptr_t)ptr & (alignment-1)) == 0);
    memset(ptr, byte, size_bytes);
}
void ptrtointtoptr(void) {
  const uint16_t alignment = 16;
  const uint16_t align_min_1 = alignment - 1;
  void * mem = malloc(1024+align_min_1);
  void *ptr = (void *)((((uint64_t)mem)+align_min_1) & ~(uint64_t)align_min_1);
  printf("0x%lu, 0x%lu\n", (unsigned long)mem, (unsigned long)ptr);
  memset_16aligned(ptr, 0, 1024, alignment);
  free(mem);
}

int main(void) { ptrtointtoptr(); }

