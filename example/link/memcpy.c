#include <stdint.h>

void new_memcpy(char *aa, char *bb, char *cc) {
  for (int32_t i = 0; i < 100; ++i) {
    cc[i] = aa[i] + bb[i];
  }
}
