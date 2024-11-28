// Tested with
// zig cc -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c
// zig cc -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/util_string.c
#include "util_string.h"

struct sCharSlice char_subslice(struct sCharSlice s_charslice, size_t start, size_t end) {
  // TODO bound checks
  struct sCharSlice res_slice = {
      .ptr = s_charslice.ptr + start,
      .len = end - start,
  };

  return res_slice;
}

ptrdiff_t char_findchar(struct sCharSlice s_charslice, char ch, size_t start, size_t end) {
  // TODO
  (void)s_charslice;
  (void)ch;
  (void)start;
  (void)end;

  return -1;
}

struct sCharSlice char_findstring(struct sCharSlice buf, struct sCharSlice search) {
  // TODO
  (void)buf;
  (void)search;
  struct sCharSlice res_slice = {.ptr = 0, .len = 0};

  return res_slice;
}

int32_t compare_sCharsSlice(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2) {

  // TODO
  (void)s_charslice1;
  (void)s_charslice2;

  return 0;
}

#define SLICE_TEST
#ifdef SLICE_TEST
#include <inttypes.h> // PRIu64
#include <stdio.h>
#include <string.h>

int main(void) {
  char buf1[10];
  memcpy(buf1, "012345678", sizeof("012345678"));
  char buf2[] = "012345678"; // 9 + 1

  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  struct sCharSlice sl1 = {
      .ptr = &buf1[0],
      .len = 10,
  };
  {
    memcpy(print_buf, sl1.ptr, sl1.len);
    fprintf(stdout, "1. slice_construction %s\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }

  {
    struct sCharSlice sub_sl1 = char_subslice(sl1, 1, 3);
    memcpy(print_buf, sub_sl1.ptr, sub_sl1.len);
    fprintf(stdout, "2. char_subslice %s expect [1,2]\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }

  {
    ptrdiff_t findres = char_findchar(sl1, '5', 2, 8);
    fprintf(stdout, "3. char_findchar res: %td expect 6\n", findres);
  }

  {
    struct sCharSlice search_str = {.ptr = "345", .len = 10};
    struct sCharSlice result_sl = char_findstring(sl1, search_str);
    memcpy(print_buf, result_sl.ptr, result_sl.len);
    fprintf(stdout, "2. char_subslice %s expect [1,2]\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }

  {
    struct sCharSlice rhs_cmp_str1 = {.ptr = "012345678", .len = 10};
    int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str1);
    fprintf(stdout, "3. compare_sCharsSlice1 res: %" PRIi32 "expect 6\n", cmp);
  }

  {
    struct sCharSlice rhs_cmp_str2 = {.ptr = buf2, .len = 10};
    int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str2);
    fprintf(stdout, "4. compare_sCharsSlice2 res: %" PRIi32 "expect 6\n", cmp);
  }

  return 0;
}

#endif
