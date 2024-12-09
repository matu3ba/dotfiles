// Tested with
// zig cc -g -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/util_string.c -o util_string23.exe && ./util_string23.exe
// TODO zig c++ -std=c++14 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage -Wno-switch-default ./example/util_string.c
// TODO zig c++ -std=c++17 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-unsafe-buffer-usage -Wno-switch-default ./example/util_string.c
// TODO zig c++ -std=c++20 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/util_string.c
// TODO zig c++ -std=c++23 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/util_string.c
// TODO zig c++ -std=c++26 -Werror -Weverything -Wno-c++98-compat-pedantic -Wno-c++20-compat -Wno-unsafe-buffer-usage -Wno-switch-default ./example/util_string.c
// TODO make OOB diagnostics optional based on safety mode
// TODO review according to https://developers.redhat.com/blog/2020/06/03/the-joys-and-perils-of-aliasing-in-c-and-c-part-2#
// TODO use vsnprintf, vfprintf, snprintf

#include "util_string.h"
#include <stdlib.h>
#include <string.h>

#define SLICE_TEST
// #define SAFETY
// #define TRACE

// null ptr compat
#if (__STDC_VERSION__ >= 202311L) // HAS_C23
#define NULLPTR nullptr
#else
#if defined(_MSC_VER) || defined(__cplusplus)
#define NULLPTR 0
#else
#define NULLPTR ((void *)0)
#endif // defined(_MSC_VER) || defined(__cplusplus)
#endif // (__STDC_VERSION__ >= 202311L) // HAS_C23

#if defined(TRACE)
#include <stdio.h>
#endif // TRACE

#if defined(SAFETY)
// TODO
#endif //SAFETY

// ====sCharSlice routines====

struct sCharSlice sCharSlice_fromcstring(char str_ptr[]) {
  size_t str_len = strlen(str_ptr);
  struct sCharSlice res = {
      .ptr = str_ptr,
      .len = str_len,
  };
  return res;
}

struct sCharSlice sCharSlice_frombuffer(char str_ptr[], size_t str_len) {
  struct sCharSlice res = {
      .ptr = str_ptr,
      .len = str_len,
  };
  return res;
}

size_t sCharSlice_tocstring(struct sCharSlice s_charslice, char cstr_ptr[], size_t cstr_len) {
  size_t bytes_to_write = s_charslice.len + 1;
  if (cstr_len < bytes_to_write)
    bytes_to_write = cstr_len;
  memcpy(cstr_ptr, s_charslice.ptr, bytes_to_write);
  cstr_ptr[bytes_to_write - 1] = 0; // string must be '\0' terminated
  return bytes_to_write;
}

size_t sCharSlice_tocstring_overlapping(struct sCharSlice s_charslice, char cstr_ptr[], size_t cstr_len) {
  size_t bytes_to_write = s_charslice.len + 1;
  if (cstr_len < bytes_to_write)
    bytes_to_write = cstr_len;
  memmove(cstr_ptr, s_charslice.ptr, bytes_to_write);
  cstr_ptr[bytes_to_write - 1] = 0; // string must be '\0' terminated
  return bytes_to_write;
}

struct sCharSlice sCharSlice_subslice(struct sCharSlice s_charslice, size_t start, size_t end) {
  struct sCharSlice res_slice = {.ptr = s_charslice.ptr, .len = 0};
  //    [  ]   reference
  // 0 nullptr ok
  // 1 [ ]     ruled out via start
  // 2  [ ]    ok
  // 3   [   ] OOB
  // 3     [ ] ok
  if (s_charslice.ptr == NULLPTR) {
    return res_slice;
  }
  if (start > s_charslice.len || end > s_charslice.len) {
    // FIXME meaningful error message for OOB
    abort();
  }

  res_slice.ptr = s_charslice.ptr + start;
  res_slice.len = end - start;

  return res_slice;
}

int32_t sCharSlice_isEqual(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2) {
  if (s_charslice1.ptr == NULLPTR || s_charslice1.ptr == NULLPTR)
    return 1;

  if (s_charslice1.len != s_charslice2.len)
    return 1;

  for (size_t i = 0; i < s_charslice1.len; i += 1)
    if (s_charslice1.ptr[i] != s_charslice2.ptr[i])
      return 1;

  return 0;
}

// ====string.h like routines====

int32_t sCharSlice_concat(struct sCharSlice *s_charslice_dest, struct sCharSlice s_charslice1,
                          struct sCharSlice s_charslice2) {
  if (s_charslice1.ptr == NULLPTR || s_charslice1.ptr == NULLPTR)
    return 1;
  if (s_charslice_dest->len < s_charslice1.len + s_charslice2.len) {
    return 1;
  }

  memcpy(&s_charslice_dest->ptr[0], s_charslice1.ptr, s_charslice1.len);
  memcpy(&s_charslice_dest->ptr[s_charslice1.len], s_charslice2.ptr, s_charslice2.len);

  s_charslice_dest->len = s_charslice1.len + s_charslice2.len;

  return 0;
}

int32_t sCharSlice_compare(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2) {
  if (s_charslice1.ptr == NULLPTR || s_charslice1.ptr == NULLPTR)
    return 1;

  if (s_charslice1.len != s_charslice2.len)
    return 1;

  for (size_t i = 0; i < s_charslice1.len; i += 1) {
    if (s_charslice1.ptr[i] < s_charslice2.ptr[i])
      return -1;
    if (s_charslice1.ptr[i] > s_charslice2.ptr[i])
      return 1;
  }

  return 0;
}

size_t sCharSlice_nonprefixlen(struct sCharSlice s_charslice, struct sCharSlice s_charslreject) {
  if (s_charslice.ptr == NULLPTR || s_charslreject.ptr == NULLPTR)
    return 0;

  size_t min_sl_len = s_charslice.len;
  if (s_charslreject.len < min_sl_len)
    min_sl_len = s_charslreject.len;

  // FIXME double check via tests
  size_t i = 0;
  for (; i < min_sl_len; i += 1) {
    if (s_charslice.ptr[i] == s_charslreject.ptr[i])
      return i;
  }

  return i;
}

size_t sCharSlice_prefixlen(struct sCharSlice s_charslice, struct sCharSlice s_charslaccept) {
  if (s_charslice.ptr == NULLPTR || s_charslaccept.ptr == NULLPTR)
    return 0;

  size_t min_sl_len = s_charslice.len;
  if (s_charslaccept.len < min_sl_len)
    min_sl_len = s_charslaccept.len;

  // FIXME double check via tests
  size_t i = 0;
  for (; i < min_sl_len; i += 1) {
    if (s_charslice.ptr[i] != s_charslaccept.ptr[i])
      return i;
  }

  return i;
}

ptrdiff_t sCharSlice_findbytes(struct sCharSlice s_charslice, struct sCharSlice s_charslbytes) {
  for (size_t sli_i = 0; sli_i < s_charslice.len; sli_i += 1) {
    for (size_t bytes_i = 0; bytes_i < s_charslbytes.len; bytes_i += 1) {
      if (s_charslice.ptr[sli_i] == s_charslbytes.ptr[bytes_i])
        return (ptrdiff_t)sli_i;
    }
  }
  return -1;
}

ptrdiff_t sCharSlice_findbyte(struct sCharSlice s_charslice, int ch) {
#if defined(SAFETY)
  if (s_charslice.ptr == NULLPTR) {
    return -1;
  }
#endif //SAFETY

  for (size_t i = 0; i < s_charslice.len; i += 1) {
    if ((int)s_charslice.ptr[i] == ch)
      return (ptrdiff_t)i;
  }
  return -1;
}

ptrdiff_t sCharSlice_reverse_findbyte(struct sCharSlice s_charslice, int ch) {
#if defined(SAFETY)
  if (s_charslice.ptr == NULLPTR) {
    return -1;
  }
#endif //SAFETY

  size_t i = s_charslice.len;
  while (i > 0) {
    i -= 1;
    if ((int)s_charslice.ptr[i] == ch)
      return (ptrdiff_t)i;
  }
  return -1;
}

struct sCharSlice sCharSlice_findstring(struct sCharSlice buf, struct sCharSlice search) {
#if defined(TRACE)
  fprintf(stderr, "TRACE: sCharSlice_findstring\n");
  char print_buf[1024];
  fprintf(stderr, "TRACE: buf.len: %zu, search.len: %zu\n", buf.len, search.len);
  if (buf.ptr == NULLPTR || search.ptr == NULLPTR) {
    fprintf(stderr, "TRACE: buf.ptr == NULLPTR: %d, search.ptr == NULLPTR: %d\n", buf.ptr == NULLPTR,
            search.ptr == NULLPTR);
  } else {
    memset(&print_buf[0], 0, 1024);
    memcpy(&print_buf[0], buf.ptr, buf.len);
    fprintf(stderr, "TRACE: buf: %s\n", &print_buf[0]);
    memset(&print_buf[0], 0, 1024);
    memcpy(&print_buf[0], search.ptr, search.len);
    fprintf(stderr, "TRACE: search: %s\n", &print_buf[0]);
  }
#endif // TRACE
  struct sCharSlice res_slice = {.ptr = buf.ptr, .len = 0};
#if defined(SAFETY)
  if (buf.ptr == NULLPTR || search.ptr == NULLPTR)
    return res_slice;
#endif //SAFETY

  size_t buf_i = 0;
  if (buf.len == 0 || search.len > buf.len)
    return res_slice;
  if (search.len == 0)
    return buf;

  while (buf_i <= buf.len - search.len) {
    size_t match_cnt = 0;
    for (size_t search_i = 0; search_i < search.len;) {
      if (buf.ptr[buf_i + search_i] != search.ptr[search_i]) {
        break;
      }
      match_cnt += 1;
      search_i += 1;
    }

    if (search.len - match_cnt == 0) {
      // result found
      res_slice.ptr = &buf.ptr[buf_i];
      res_slice.len = search.len;
      return res_slice;
    }

    if (match_cnt > 0)
      buf_i += match_cnt;
    else
      buf_i += 1;
  }

  return res_slice;
}

struct sCharSlice sCharSlice_tokenize(struct sCharSlice s_charslice, struct sCharSlice delimiter) {
  struct sCharSlice result_sl = {.ptr = s_charslice.ptr, .len = s_charslice.len};

  // omit delimiter prefixes
  struct sCharSlice sliding_window = sCharSlice_findstring(s_charslice, delimiter);
  while (sliding_window.ptr == delimiter.ptr && sliding_window.len == delimiter.len) {
    sliding_window = sCharSlice_findstring(s_charslice, delimiter);
    result_sl.ptr = sliding_window.ptr + sliding_window.len; // points one past delimiter string
    result_sl.len = s_charslice.len - sliding_window.len;
  }

  // handle empty string before or after omitting delimiter prefix
  if (result_sl.len == 0)
    return result_sl;

  return result_sl; // FIXME
}

#ifdef SLICE_TEST
#include <inttypes.h> // PRIu64
#include <stdio.h>
#include <string.h>

int main(void) {
  char buf1[10];
  memcpy(buf1, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
  struct sCharSlice sl1 = sCharSlice_fromcstring(&buf1[0]);

  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  // testing sCharSlice routines
  {
    struct sCharSlice expect_sl = sCharSlice_fromcstring("012345678");
    if (sCharSlice_isEqual(sl1, expect_sl) != 0) {
      memcpy(print_buf, sl1.ptr, sl1.len);
      fprintf(stderr, "1. sCharSlice_fromcstring [%s], sl1.len: [%zu] expect [012345678], [9]\n", print_buf, sl1.len);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    char buf2[10];
    size_t printed = sCharSlice_tocstring(sl1, &buf2[0], 10);
    if (strncmp(sl1.ptr, &buf2[0], sl1.len) != 0) {
      memcpy(print_buf, buf2, 10);
      fprintf(stderr, "1. sCharSlice_tocstring [%s], printed: [%zu] expect [012345678], [10]\n", print_buf, printed);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    char buf2[10];
    memcpy(buf2, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
    struct sCharSlice sl2 = sCharSlice_frombuffer(&buf1[0], sizeof(buf2));
    size_t printed = sCharSlice_tocstring_overlapping(sl2, &buf2[0], 10);
    if (strncmp(sl2.ptr, &buf2[0], sl2.len) != 0) {
      memcpy(print_buf, buf2, 10);
      fprintf(stderr, "1. sCharSlice_tocstring_overlapping [%s], printed: [%zu] expect [012345678], [10]\n", print_buf,
              printed);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice sub_sl1 = sCharSlice_subslice(sl1, 1, 3);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("12");
    if (sCharSlice_isEqual(sub_sl1, expect_sl) != 0) {
      memcpy(print_buf, sub_sl1.ptr, sub_sl1.len);
      fprintf(stderr, "2. sCharSlice_subslice [%s] expect [12]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  // testing string.h like routines

  {
    struct sCharSlice sli1 = sCharSlice_fromcstring("12");
    struct sCharSlice sli2 = sCharSlice_fromcstring("34");
    char buf[10];
    struct sCharSlice res_sl = sCharSlice_frombuffer(&buf[0], sizeof(buf));
    int32_t st = sCharSlice_concat(&res_sl, sli1, sli2);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("1234");
    if (st != 0 || sCharSlice_isEqual(res_sl, expect_sl) != 0) {
      memcpy(print_buf, res_sl.ptr, res_sl.len);
      fprintf(stderr, "2. sCharSlice_concat [%s] expect [1234]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    // FIXME doule check by result of strncmp
    struct sCharSlice sli1 = sCharSlice_fromcstring("12");
    struct sCharSlice sli2 = sCharSlice_fromcstring("34");
    struct sCharSlice sli3 = sCharSlice_fromcstring("");
    struct sCharSlice sli4 = sCharSlice_fromcstring("12");
    int32_t st = sCharSlice_compare(sli1, sli2);
    if (st != -1)
      fprintf(stderr, "sCharSlice_compare1 [%d] expect [-1]\n", st);
    st = sCharSlice_compare(sli1, sli3);
    if (st != 1)
      fprintf(stderr, "sCharSlice_compare2 [%d] expect [1]\n", st);
    st = sCharSlice_compare(sli1, sli4);
    if (st != 0)
      fprintf(stderr, "sCharSlice_compare3 [%d] expect [0]\n", st);
    st = sCharSlice_compare(sli2, sli3);
    if (st != 1)
      fprintf(stderr, "sCharSlice_compare4 [%d] expect [1]\n", st);
    st = sCharSlice_compare(sli2, sli4);
    if (st != 1)
      fprintf(stderr, "sCharSlice_compare5 [%d] expect [1]\n", st);
  }

  {
    ptrdiff_t findres = sCharSlice_findbyte(sl1, '1');
    if (findres != 1)
      fprintf(stderr, "sCharSlice_findbyte1 res: %td expect 1\n", findres);
    findres = sCharSlice_findbyte(sl1, '8');
    if (findres != 8)
      fprintf(stderr, "sCharSlice_findbyte2 res: %td expect 8\n", findres);
    findres = sCharSlice_findbyte(sl1, '9');
    if (findres != -1)
      fprintf(stderr, "sCharSlice_findbyte3 res: %td expect -1\n", findres);
    findres = sCharSlice_findbyte(sl1, '9');
    if (findres != -1)
      fprintf(stderr, "sCharSlice_findbyte4 res: %td expect -1\n", findres);
    findres = sCharSlice_findbyte(sl1, '0');
    if (findres != 0)
      fprintf(stderr, "sCharSlice_findbyte5 res: %td expect 0\n", findres);
    findres = sCharSlice_findbyte(sl1, '5');
    if (findres != 5)
      fprintf(stderr, "sCharSlice_findbyte6 res: %td expect 5\n", findres);
    findres = sCharSlice_findbyte(sl1, '5');
    if (findres != 5)
      fprintf(stderr, "sCharSlice_findbyte7 res: %td expect 5\n", findres);
  }

  {
    struct sCharSlice search_str = sCharSlice_fromcstring("90");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(12) [%s] expect []\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice search_str = sCharSlice_fromcstring("345");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("345");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(345) [%s] expect [345]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice search_str = sCharSlice_fromcstring("012345678");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("012345678");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(012345678) [%s] expect [012345678]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice search_str = sCharSlice_fromcstring("12");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("12");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(12) [%s] expect [12]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice search_str = sCharSlice_fromcstring("78");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromcstring("78");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "sCharSlice_findstring1(12) [%s] expect [78]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }

  {
    struct sCharSlice cmp_sl = sCharSlice_fromcstring("012345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql != 0)
      fprintf(stderr, "sCharSlice_findstring2(012345678) [%d] expect [0]\n", eql);
  }

  {
    struct sCharSlice cmp_sl = sCharSlice_fromcstring("012345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql != 0)
      fprintf(stderr, "sCharSlice_findstring3(012345678) [%d] expect [0]\n", eql);
  }

  {
    struct sCharSlice cmp_sl = sCharSlice_fromcstring("12345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql == 0)
      fprintf(stderr, "sCharSlice_findstring4(12345678) [%d] expect [1]\n", eql);
  }

  {
    struct sCharSlice cmp_sl = sCharSlice_fromcstring("123456789");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql == 0)
      fprintf(stderr, "sCharSlice_findstring5(123456789) [%d] expect [1]\n", eql);
  }

  // {
  //   struct sCharSlice rhs_cmp_str1 = {.ptr = "012345678", .len = 10};
  //   int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str1);
  //   fprintf(stderr, "compare_sCharsSlice1 res: %" PRIi32 "expect 6\n", cmp);
  // }
  //
  // {
  //   struct sCharSlice rhs_cmp_str2 = {.ptr = buf2, .len = 10};
  //   int32_t cmp = compare_sCharsSlice(sl1, rhs_cmp_str2);
  //   fprintf(stderr, "compare_sCharsSlice2 res: %" PRIi32 "expect 6\n", cmp);
  // }

  return 0;
}

#endif
