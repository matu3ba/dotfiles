#include "memcpy_avx.h"
/// requires 32 byte aligned src, dest; src and dest must not overlap
void memcpy_avx(__m256i * __restrict src, __m256i * __restrict dest, size_t n) {
  size_t n_vec = n / sizeof(__m256i);
  for(size_t i=0; i<n_vec; i+=1) {
    const __m256i temp = _mm256_load_si256(src);
    _mm256_store_si256(dest, temp);
    src += 1;
    dest += 1;
  }
}

//====main.c
// #include <stdio.h>
// #include <stdint.h>
// #include "memcpy_avx.h"
// int main(void) {
//   uint8_t mem_src[1024] = { 0 };
//   uint8_t mem_dest[1024] = { 0 };
//   const uint16_t alignment = 32;
//   const uint16_t align_min_1 = alignment - 1;
//   __m256i * p_src = (void *)(((uintptr_t)mem_src+align_min_1) & ~(uintptr_t)align_min_1);
//   __m256i * p_dest = (void *)(((uintptr_t)mem_dest+align_min_1) & ~(uintptr_t)align_min_1);
//   memcpy_avx(p_src, p_dest, 4);
//   fprintf(stdout, "p_src: %p, p_dest: %p\n", (void*)p_src, (void*)p_dest);
//   return 0;
// }
// clang -Weverything -O3 -march=native main.c memcpy_avx.c && ./a.out
// Output (contains C++ warnings):
// extern.c:8:5: warning: unsafe pointer arithmetic [-Wunsafe-buffer-usage]
//     8 |     src += 1;
//       |     ^~~
// extern.c:9:5: warning: unsafe pointer arithmetic [-Wunsafe-buffer-usage]
//     9 |     dest += 1;
//       |     ^~~~
// 2 warnings generated.
// p_src: 0x7ffceb985a60, p_dest: 0x7ffceb985660
