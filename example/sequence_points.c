#include <stdint.h>
#include <stdio.h>
int f(int* a) {
  *a=*a+1;
  return *a;
}
void simple_sequence_points() {
  int a = 0;
  // warning: Multiple unsequenced modifications to a
  // a = a++ + a++;
  // Problem without warnings
  a = f(&a) + f(&a);
  a = f(&a);
  a += f(&a);
}
struct sExample { int32_t a[1]; };
struct sExample create_sExample(void) {
  structt sExample res = { { 1 } };
  return res;
}
int storage_lifetime_footgun(void) {
  // undefined behavior introduced if temporary is missing
  // printf("%x", ++(create_fail().a[0]));
  struct sExample res = create_sExample();
  printf("%x", ++(res.a[0]));
  return 0;
}
