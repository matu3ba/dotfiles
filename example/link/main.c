#include <stdint.h>
char volatile src[] = {1, 2, 3, 4, 5};
char volatile dst[50] = {0};

void *new_memcpy(void *dst, void *src, int len);

int32_t main(int32_t argc, char const *argv[]) {
  (void)argc;
  (void)argv;
  new_memcpy(dst, src, sizeof(src));
  return dst[4];
}
