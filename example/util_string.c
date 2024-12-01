// Tested with
// zig cc -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c
// zig cc -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/util_string.c
#include "util_string.h"

struct sCharSlice char_subslice(struct sCharSlice s_charslice, size_t start, size_t end) {
  // TODO SAFETY with nullptr checks

  // 1 [ ]
  // 2  [ ]
  // 3   [ ]
  // 4 [   ]

  // TODO bound checks

  struct sCharSlice res_slice = {
      .ptr = s_charslice.ptr + start,
      .len = end - start,
  };

  return res_slice;
}

ptrdiff_t char_findchar(struct sCharSlice s_charslice, char ch, size_t start, size_t end) {
  // TODO SAFETY with nullptr checks

  size_t i = start;
  if (s_charslice.len < start || s_charslice.len < end)
    return -1;
  for (; i < end; i += 1) {
    if (s_charslice.ptr[i] == ch)
      return (ptrdiff_t)i;
  }
  return -1;
}

struct sCharSlice char_findstring(struct sCharSlice buf, struct sCharSlice search) {
  // TODO SAFETY with nullptr checks

  // edge case:
  // aaab,    search aab
  // a        prefix_match_cnt = 1
  // aa       prefix_match_cnt = 2
  // aaa      prefix_match_cnt = 2, forward search_len-match_cnt = 1

  // zxyaab   search aab
  // zxy      prefix_match_cnt = 0, forward search_len-match_cnt = 3

  size_t buf_i = 0;
  struct sCharSlice res_slice = {.ptr = buf.ptr, .len = 0};
  if (buf.len == 0 || search.len > buf.len) {
    return res_slice;
  }
  if (search.len == 0)
    return buf;

  size_t prefix_match_cnt = 0;
  // forward progress invariant: prefix_match_cnt > 0, iff forward search_len-match_cnt > 0
  // meaning result was found.
  // bound invariant: search.len <= buf.len => 0 <= buf.len - search.len
  while (buf_i < buf.len - search.len) {
    size_t match_cnt = 0;
    for (size_t search_i = 0; search_i < search.len; search_i += 1) {
      if (buf.ptr[buf_i + search_i] != search.ptr[search_i]) {
        prefix_match_cnt = search.len - match_cnt;
        break;
      }
      match_cnt += 1;
      search_i += 1;
    }

    if (prefix_match_cnt == 0) {
      // result found
      res_slice.ptr = &buf.ptr[buf_i];
      res_slice.len = search.len;
      return res_slice;
    }

    buf_i += prefix_match_cnt;
  }

  return res_slice;
}

// TODO return prefix of two slices
// int32_t compare_sCharsSlice(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2) {
//   // TODO SAFETY with nullptr checks
//
//   if (s_charslice1.len != s_charslice2.len)
//     return 1;
//
//   for (size_t i = 0; i < s_charslice1.len; i += 1)
//     if (s_charslice1.ptr[i] != s_charslice2.ptr[i])
//       return 1;
//
//   return 0;
// }

int32_t isEqual_sCharsSlice(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2) {
  // TODO SAFETY with nullptr checks

  if (s_charslice1.len != s_charslice2.len)
    return 1;

  for (size_t i = 0; i < s_charslice1.len; i += 1)
    if (s_charslice1.ptr[i] != s_charslice2.ptr[i])
      return 1;

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

  (void)buf2;

  // {
  //   struct sCharSlice rhs_cmp_str1 = {.ptr = "012345678", .len = 10};
  //   int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str1);
  //   fprintf(stdout, "3. compare_sCharsSlice1 res: %" PRIi32 "expect 6\n", cmp);
  // }
  //
  // {
  //   struct sCharSlice rhs_cmp_str2 = {.ptr = buf2, .len = 10};
  //   int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str2);
  //   fprintf(stdout, "4. compare_sCharsSlice2 res: %" PRIi32 "expect 6\n", cmp);
  // }

  return 0;
}

#endif
