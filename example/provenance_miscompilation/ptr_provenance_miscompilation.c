#include <stddef.h>
#include <stdio.h>
#include "extern.h"
// Removing restrict makes the miscompilation go away
size_t f(size_t * restrict ptr_to_x);
size_t f(size_t * restrict ptr_to_x) {
  size_t * p = ptr_to_x;
  *p = 1;
  if (p == &x) {
      // Expected branch, taken only in Debug mode
      *p = 2;
  }
  return *p;
}
int main(void) {
  if (f(&x) == 1) fprintf(stderr, "panic : p != &x\n");
}
// clang -O0 -Weverything ptr_provenance_miscompilation.c extern.c && ./a.out
// output:
// clang -O1 -Weverything ptr_provenance_miscompilation.c extern.c && ./a.out
// output: panic : p != &x
// cerberus ptr_provenance_miscompilation.c extern.c
// output:
// merging everything into ptr_provenance_miscompilation.c
// cerberus ptr_provenance_miscompilation.c
// output:
