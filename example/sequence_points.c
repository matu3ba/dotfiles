#include <stdint.h>
#include <stdio.h>

static int f(int *a) {
  *a = *a + 1;
  return *a;
}
static void simple_sequence_points(void) {
  int a = 0;
  // warning: Multiple unsequenced modifications to a
  // a = a++ + a++;
  // Problem without warnings
  a = f(&a) + f(&a);
  a = f(&a);
  a += f(&a);
}
struct sExample {
  uint32_t a[1];
};
static struct sExample create_sExample(void) {
  struct sExample res = {{1}};
  return res;
}
static int storage_lifetime_footgun(void) {
  // undefined behavior introduced if temporary is missing
  // printf("%x", ++(create_fail().a[0]));
  struct sExample res = create_sExample();
  printf("%x", ++(res.a[0]));
  return 0;
}

int32_t main(void) {
  simple_sequence_points();
  storage_lifetime_footgun();
}
