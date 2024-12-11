// Tested with
// zig cc -g -DSLICE_TEST -DSAFETY -DTRACE -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -DSLICE_TEST -DSAFETY -DTRACE -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -DSLICE_TEST -DSAFETY -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -DSLICE_TEST -DSAFETY -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -DSLICE_TEST -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -DSLICE_TEST -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/util_string.c -o util_string23.exe && ./util_string23.exe
// zig cc -g -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/util_string.c -o util_string99.exe && ./util_string99.exe
// zig cc -g -std=c11 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./example/util_string.c -o util_string99.exe && ./util_string99.exe
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
#include <assert.h>
#include <stddef.h>
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

struct sCharSlice sCharSlice_fromliteral(char str_ptr[]) {
  size_t str_len = strlen(str_ptr);
  struct sCharSlice res = {
      .ptr = str_ptr,
      .len = str_len,
  };
  return res;
}

struct sCharSlice sCharSlice_frombuffer(char str_ptr[], size_t str_size_no0term) {
  struct sCharSlice res = {
      .ptr = str_ptr,
      .len = str_size_no0term,
  };
  return res;
}

struct sCharSlice sCharSlice_fromcstrbuffer(char str_ptr[], size_t str_size_incl0term) {
  struct sCharSlice res = {
      .ptr = str_ptr,
      .len = (((ptrdiff_t)str_size_incl0term - 1) < 0) ? 0 : str_size_incl0term - 1,
  };
  return res;
}

size_t sCharSlice_tocstring(struct sCharSlice s_char_sl, char cstr_ptr[], size_t cstr_len) {
  size_t bytes_to_write = s_char_sl.len + 1;
  if (cstr_len < bytes_to_write)
    bytes_to_write = cstr_len;
  memcpy(cstr_ptr, s_char_sl.ptr, bytes_to_write);
  cstr_ptr[bytes_to_write - 1] = 0; // string must be '\0' terminated
  return bytes_to_write;
}

size_t sCharSlice_tocstring_overlapping(struct sCharSlice s_char_sl, char cstr_ptr[], size_t cstr_len) {
  size_t bytes_to_write = s_char_sl.len + 1;
  if (cstr_len < bytes_to_write)
    bytes_to_write = cstr_len;
  memmove(cstr_ptr, s_char_sl.ptr, bytes_to_write);
  cstr_ptr[bytes_to_write - 1] = 0; // string must be '\0' terminated
  return bytes_to_write;
}

struct sCharSlice sCharSlice_subslice(struct sCharSlice s_char_sl, size_t start, size_t end) {
  struct sCharSlice res_slice = {.ptr = s_char_sl.ptr, .len = 0};
  //    [  ]   reference
  // 0 nullptr ok
  // 1 [ ]     ruled out via start
  // 2  [ ]    ok
  // 3   [   ] OOB
  // 3     [ ] ok
  if (s_char_sl.ptr == NULLPTR) {
    return res_slice;
  }
  if (start > s_char_sl.len || end > s_char_sl.len) {
    // FIXME meaningful error message for OOB
    abort();
  }

  res_slice.ptr = s_char_sl.ptr + start;
  res_slice.len = end - start;

  return res_slice;
}

int32_t sCharSlice_isEqual(struct sCharSlice s_char_sl1, struct sCharSlice s_char_sl2) {
  if (s_char_sl1.ptr == NULLPTR || s_char_sl1.ptr == NULLPTR)
    return 1;

  if (s_char_sl1.len != s_char_sl2.len)
    return 1;

  for (size_t i = 0; i < s_char_sl1.len; i += 1)
    if (s_char_sl1.ptr[i] != s_char_sl2.ptr[i])
      return 1;

  return 0;
}

// ====string.h like routines====

int32_t sCharSlice_concat(struct sCharSlice *s_charslice_dest, struct sCharSlice s_char_sl1,
                          struct sCharSlice s_char_sl2) {
  if (s_char_sl1.ptr == NULLPTR || s_char_sl1.ptr == NULLPTR)
    return 1;
  if (s_charslice_dest->len < s_char_sl1.len + s_char_sl2.len) {
    return 1;
  }

  memcpy(&s_charslice_dest->ptr[0], s_char_sl1.ptr, s_char_sl1.len);
  memcpy(&s_charslice_dest->ptr[s_char_sl1.len], s_char_sl2.ptr, s_char_sl2.len);

  s_charslice_dest->len = s_char_sl1.len + s_char_sl2.len;

  return 0;
}

int32_t sCharSlice_compare(struct sCharSlice s_char_sl1, struct sCharSlice s_char_sl2) {
  if (s_char_sl1.ptr == NULLPTR || s_char_sl1.ptr == NULLPTR)
    return 1;

  if (s_char_sl1.len != s_char_sl2.len)
    return 1;

  for (size_t i = 0; i < s_char_sl1.len; i += 1) {
    if (s_char_sl1.ptr[i] < s_char_sl2.ptr[i])
      return -1;
    if (s_char_sl1.ptr[i] > s_char_sl2.ptr[i])
      return 1;
  }

  return 0;
}

size_t sCharSlice_nonprefixlen(struct sCharSlice s_char_sl, struct sCharSlice s_char_sl_reject) {
  if (s_char_sl.ptr == NULLPTR || s_char_sl_reject.ptr == NULLPTR)
    return 0;

  if (s_char_sl_reject.len == 0)
    return s_char_sl.len;

  struct sCharSlice find_sl = sCharSlice_findstring(s_char_sl, s_char_sl_reject);
  if (find_sl.len == 0) {
    return s_char_sl.len;
  } else {
    return (size_t)(&find_sl.ptr[0] - &s_char_sl.ptr[0]);
  }
}

size_t sCharSlice_prefixlen(struct sCharSlice s_char_sl, struct sCharSlice s_char_sl_accept) {
  if (s_char_sl.ptr == NULLPTR || s_char_sl_accept.ptr == NULLPTR)
    return 0;

  if (s_char_sl_accept.len == 0)
    return 0;

  size_t i = 0;
  while (i < s_char_sl.len) {
    for (size_t acc_i = 0; acc_i < s_char_sl_accept.len; acc_i += 1) {
      if (s_char_sl.ptr[i] != s_char_sl_accept.ptr[i])
        return i;
      i += 1;
      if (i == s_char_sl.len)
        return i;
    }
  }
  abort(); // unreachable
}

ptrdiff_t sCharSlice_findbytes(struct sCharSlice s_char_sl, struct sCharSlice s_charslbytes) {
  for (size_t sli_i = 0; sli_i < s_char_sl.len; sli_i += 1) {
    for (size_t bytes_i = 0; bytes_i < s_charslbytes.len; bytes_i += 1) {
      if (s_char_sl.ptr[sli_i] == s_charslbytes.ptr[bytes_i])
        return (ptrdiff_t)sli_i;
    }
  }
  return -1;
}

ptrdiff_t sCharSlice_findbyte(struct sCharSlice s_char_sl, int ch) {
#if defined(SAFETY)
  if (s_char_sl.ptr == NULLPTR) {
    return -1;
  }
#endif //SAFETY

  for (size_t i = 0; i < s_char_sl.len; i += 1) {
    if ((int)s_char_sl.ptr[i] == ch)
      return (ptrdiff_t)i;
  }
  return -1;
}

ptrdiff_t sCharSlice_reverse_findbyte(struct sCharSlice s_char_sl, int ch) {
#if defined(SAFETY)
  if (s_char_sl.ptr == NULLPTR) {
    return -1;
  }
#endif //SAFETY

  size_t i = s_char_sl.len;
  while (i > 0) {
    i -= 1;
    if ((int)s_char_sl.ptr[i] == ch)
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

struct sCharSlice_Interval sCharSlice_tokenize(struct sCharSlice s_char_sl, struct sCharSlice delimiter, size_t start) {
  size_t start_i = start;

  if (delimiter.len == 0) {
    struct sCharSlice_Interval tokenized = {
        .start = start_i,
        .end = s_char_sl.len,
    };
    return tokenized;
  }

  // omit delimiter prefixes
  while (start_i < s_char_sl.len) {
    for (size_t delim_i = 0; delim_i < delimiter.len; delim_i += 1) {
      if (start_i == s_char_sl.len) {
        struct sCharSlice_Interval tokenized = {
            .start = start_i,
            .end = start_i,
        };
        return tokenized;
      }
      if (s_char_sl.ptr[start_i] != delimiter.ptr[delim_i])
        goto END_OMIT_PREFIXES;
      start_i += 1;
    }
  }
END_OMIT_PREFIXES:;
  struct sCharSlice next_sl = sCharSlice_subslice(s_char_sl, start_i, s_char_sl.len);
  struct sCharSlice find_sl = sCharSlice_findstring(next_sl, delimiter);
  if (find_sl.len != 0) {
    struct sCharSlice_Interval tokenized = {
        .start = start_i,
        .end = (size_t)(find_sl.ptr - s_char_sl.ptr),
    };
    return tokenized;
  } else {
    struct sCharSlice_Interval tokenized = {
        .start = start_i,
        .end = s_char_sl.len,
    };
    return tokenized;
  }
}

#if defined(SLICE_TEST)
#include <inttypes.h> // PRIu64
#include <stdio.h>
#include <string.h>

// C99 basic string literal check
#define IS_STR_LIT(x) (void)((void)(x), &("" x ""))
#define MAXSTRLEN_OF_BUF(x) sizeof(x) - 1
// __FILE_NAME__
// __FILE__
#define CHECK_EQ(VAR, EXPECTED)                                                           \
  do {                                                                                    \
    if (VAR != EXPECTED) {                                                                \
      fprintf(stdout, "%s:%d %zu != %d (expected)\n", __FILE__, __LINE__, VAR, EXPECTED); \
      *status += 1;                                                                       \
    }                                                                                     \
  } while (0)

static void test_sCharSlice_fromliteral(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  char buf1[10];
  memcpy(buf1, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
  struct sCharSlice sl1 = sCharSlice_frombuffer(&buf1[0], MAXSTRLEN_OF_BUF(buf1));

  IS_STR_LIT("012345678");
  struct sCharSlice expect_sl = sCharSlice_fromliteral("012345678");
  if (sCharSlice_isEqual(sl1, expect_sl) != 0) {
    *status += 1;
    memcpy(print_buf, sl1.ptr, sl1.len);
    fprintf(stderr, "sCharSlice_fromliteral [%s], sl1.len, expect_sl.len: [%zu, %zu] expect [012345678], [9]\n",
            print_buf, sl1.len, expect_sl.len);
    memset(&print_buf[0], 0, 1024);
  }
}

static void test_sCharSlice_fromcstrbuffer(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  struct sCharSlice expect_sl = sCharSlice_fromliteral("012345678");

  IS_STR_LIT("012345678");
  char buf[10];
  memcpy(buf, "012345678", sizeof("012345678"));
  struct sCharSlice sl1 = sCharSlice_fromcstrbuffer(&buf[0], sizeof(buf));
  if (sCharSlice_isEqual(sl1, expect_sl) != 0) {
    *status += 1;
    memcpy(print_buf, sl1.ptr, sl1.len);
    fprintf(stderr, "sCharSlice_fromcstrbuffer [%s], sl1.len, expect_sl.len: [%zu, %zu] expect [012345678], [9]\n",
            print_buf, sl1.len, expect_sl.len);
    memset(&print_buf[0], 0, 1024);
  }
}

static void test_sCharSlice_tocstring(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  struct sCharSlice sl1 = sCharSlice_fromliteral("012345678");

  char buf[10];
  size_t printed = sCharSlice_tocstring(sl1, &buf[0], 10);
  if (strncmp(sl1.ptr, &buf[0], sl1.len) != 0) {
    *status += 1;
    memcpy(print_buf, buf, 10);
    fprintf(stderr, "sCharSlice_tocstring [%s], printed: [%zu] expect [012345678], [10]\n", print_buf, printed);
    memset(&print_buf[0], 0, 1024);
  }
}

static void test_sCharSlice_tocstring_overlapping(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  char buf2[10];
  memcpy(buf2, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
  struct sCharSlice sl2 = sCharSlice_frombuffer(&buf2[0], MAXSTRLEN_OF_BUF(buf2));
  size_t printed = sCharSlice_tocstring_overlapping(sl2, &buf2[0], 10);
  if (strncmp(sl2.ptr, &buf2[0], sl2.len) != 0) {
    *status += 1;
    memcpy(print_buf, buf2, 10);
    fprintf(stderr, "1. sCharSlice_tocstring_overlapping [%s], printed: [%zu] expect [012345678], [10]\n", print_buf,
            printed);
    memset(&print_buf[0], 0, 1024);
  }
}

// also tests sCharSlice_isEqual
static void test_sCharSlice_subslice(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  char buf1[10];
  memcpy(buf1, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
  struct sCharSlice sl1 = sCharSlice_frombuffer(&buf1[0], MAXSTRLEN_OF_BUF(buf1));

  struct sCharSlice sub_sl1 = sCharSlice_subslice(sl1, 1, 3);
  struct sCharSlice expect_sl = sCharSlice_fromliteral("12");
  if (sCharSlice_isEqual(sub_sl1, expect_sl) != 0) {
    *status += 1;
    memcpy(print_buf, sub_sl1.ptr, sub_sl1.len);
    fprintf(stderr, "2. sCharSlice_subslice [%s] expect [12]\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }
}

static void test_sCharSlice_isEqual(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  char buf1[10];
  memcpy(buf1, "012345678", sizeof("012345678")); // 9 + 1, sizeof = 10
  struct sCharSlice sl1 = sCharSlice_frombuffer(&buf1[0], MAXSTRLEN_OF_BUF(buf1));

  { // sCharSlice_isEqual
    struct sCharSlice cmp_sl = sCharSlice_fromliteral("012345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql != 0) {
      *status += 1;
      fprintf(stderr, "sCharSlice_isEqual(012345678) [%d] expect [0]\n", eql);
    }
  }
  {
    struct sCharSlice cmp_sl = sCharSlice_fromliteral("012345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql != 0) {
      *status += 1;
      fprintf(stderr, "sCharSlice_isEqual(012345678) [%d] expect [0]\n", eql);
    }
  }
  {
    struct sCharSlice cmp_sl = sCharSlice_fromliteral("12345678");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql == 0) {
      *status += 1;
      fprintf(stderr, "sCharSlice_isEqual(12345678) [%d] expect [1]\n", eql);
    }
  }
  {
    struct sCharSlice cmp_sl = sCharSlice_fromliteral("123456789");
    int32_t eql = sCharSlice_isEqual(sl1, cmp_sl);
    if (eql == 0) {
      *status += 1;
      fprintf(stderr, "sCharSlice_isEqual(123456789) [%d] expect [1]\n", eql);
    }
  }
}

static void test_sCharSlice_concat(int32_t *status) {
  // also compares with strncat
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  char cat_buf[1024];
  memset(&cat_buf[0], 0, 1024);
  char const *cstr1 = "12";
  char const *cstr2 = "34";

  // strcat(&cat_buf[0], &cstr1[0]);
  // strcat(&cat_buf[0 + strlen(cstr1)], &cstr2[0]);
  // prevent clangd from complaining about safety
  strncat(&cat_buf[0], &cstr1[0], strlen(cstr1) + 1);
  strncat(&cat_buf[0 + strlen(cstr1)], &cstr2[0], strlen(cstr2) + 1);

  struct sCharSlice sli1 = sCharSlice_fromliteral("12");
  struct sCharSlice sli2 = sCharSlice_fromliteral("34");
  char buf[10];
  struct sCharSlice res_sl = sCharSlice_frombuffer(&buf[0], MAXSTRLEN_OF_BUF(buf));
  int32_t st = sCharSlice_concat(&res_sl, sli1, sli2);
  struct sCharSlice expect_sl = sCharSlice_fromliteral("1234");
  if (st != 0 || sCharSlice_isEqual(res_sl, expect_sl) != 0) {
    *status += 1;
    memcpy(print_buf, res_sl.ptr, res_sl.len);
    fprintf(stderr, "2. sCharSlice_concat [%s] expect [1234]\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }

  struct sCharSlice sl_strcat = sCharSlice_fromcstrbuffer(&cat_buf[0], strlen(cat_buf) + 1);
  if (sCharSlice_isEqual(sl_strcat, expect_sl) != 0) {
    *status += 1;
    memcpy(print_buf, &sl_strcat.ptr, sl_strcat.len);
    fprintf(stderr, "2. sCharSlice_concat [%s] expect [1234]\n", print_buf);
    memset(&print_buf[0], 0, 1024);
  }
}

static void test_sCharSlice_compare(int32_t *status) {
  // also compares with strcmp

  struct sCharSlice sli1 = sCharSlice_fromliteral("12");
  struct sCharSlice sli2 = sCharSlice_fromliteral("34");
  struct sCharSlice sli3 = sCharSlice_fromliteral("");
  struct sCharSlice sli4 = sCharSlice_fromliteral("12");
  int st_string_ref = strcmp("12", "34");
  int32_t st = sCharSlice_compare(sli1, sli2);
  if (st != -1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare1 [%d] expect [-1]\n", st);
  }
  if (st != st_string_ref) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare1 != ref [%d] expect [-1]\n", st_string_ref);
  }

  st = sCharSlice_compare(sli1, sli3);
  if (st != 1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare2 [%d] expect [1]\n", st);
  }
  st_string_ref = strcmp("12", "");
  if (st != st_string_ref) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare2 != ref [%d] expect [-1]\n", st_string_ref);
  }

  st = sCharSlice_compare(sli1, sli4);
  if (st != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare3 [%d] expect [0]\n", st);
  }
  st_string_ref = strcmp("12", "12");
  if (st != st_string_ref) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare3 != ref [%d] expect [-1]\n", st_string_ref);
  }

  st = sCharSlice_compare(sli2, sli3);
  if (st != 1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare4 [%d] expect [1]\n", st);
  }
  st_string_ref = strcmp("34", "");
  if (st != st_string_ref) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare4 != ref [%d] expect [-1]\n", st_string_ref);
  }

  st = sCharSlice_compare(sli2, sli4);
  if (st != 1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare5 [%d] expect [1]\n", st);
  }
  st_string_ref = strcmp("34", "12");
  if (st != st_string_ref) {
    *status += 1;
    fprintf(stderr, "sCharSlice_compare5 != ref [%d] expect [-1]\n", st_string_ref);
  }
}

static void test_sCharSlice_nonprefixlen(int32_t *status) {
  // also compares with strcspn
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  struct sCharSlice searched_sl = sCharSlice_fromliteral("012345678");

  struct sCharSlice reject_sl1 = sCharSlice_fromliteral("78");
  size_t res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl, reject_sl1);
  if (res_nonprefixlen != 7) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen1 res: %zu expect 7\n", res_nonprefixlen);
  }
  size_t ref_strcspn = strcspn("012345678", "78");
  if (ref_strcspn != 7) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen2 ref_strcspn: %zu expect 7\n", ref_strcspn);
  }

  struct sCharSlice reject_sl2 = sCharSlice_fromliteral("0");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl, reject_sl2);
  if (res_nonprefixlen != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen3 res: %zu expect 0\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("012345678", "0");
  if (ref_strcspn != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen4 ref_strcspn: %zu expect 0\n", ref_strcspn);
  }

  struct sCharSlice reject_sl3 = sCharSlice_fromliteral("012345678");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl, reject_sl3);
  if (res_nonprefixlen != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen5 res: %zu expect 0\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("012345678", "012345678");
  if (ref_strcspn != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen6 ref_strcspn: %zu expect 0\n", ref_strcspn);
  }

  struct sCharSlice reject_sl4 = sCharSlice_fromliteral("9");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl, reject_sl4);
  if (res_nonprefixlen != 9) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen7 res: %zu expect 9\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("012345678", "9");
  if (ref_strcspn != 9) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen8 ref_strcspn: %zu expect 9\n", ref_strcspn);
  }

  struct sCharSlice reject_sl5 = sCharSlice_fromliteral("");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl, reject_sl5);
  if (res_nonprefixlen != 9) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen9 res: %zu expect 9\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("012345678", "");
  if (ref_strcspn != 9) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen10 ref_strcspn: %zu expect 9\n", ref_strcspn);
  }

  struct sCharSlice searched_sl1 = sCharSlice_fromliteral("");
  struct sCharSlice reject_sl6 = sCharSlice_fromliteral("");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl1, reject_sl6);
  if (res_nonprefixlen != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen11 res: %zu expect 0\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("", "");
  if (ref_strcspn != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen12 ref_strcspn: %zu expect 0\n", ref_strcspn);
  }

  struct sCharSlice reject_sl7 = sCharSlice_fromliteral("a");
  res_nonprefixlen = sCharSlice_nonprefixlen(searched_sl1, reject_sl7);
  if (res_nonprefixlen != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen13 res: %zu expect 0\n", res_nonprefixlen);
  }
  ref_strcspn = strcspn("", "a");
  if (ref_strcspn != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_nonprefixlen14 ref_strcspn: %zu expect 0\n", ref_strcspn);
  }
}

static void test_sCharSlice_prefixlen(int32_t *status) {
  // also compares with strspn
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  struct sCharSlice searched_sl = sCharSlice_fromliteral("012345678");
  struct sCharSlice accept_sl1 = sCharSlice_fromliteral("01234");

  size_t res_prefixlen = sCharSlice_prefixlen(searched_sl, accept_sl1);
  if (res_prefixlen != 5) {
    *status += 1;
    fprintf(stderr, "sCharSlice_prefixlen1 res: %zu expect 5\n", res_prefixlen);
  }
  size_t ref_strspn = strspn("012345678", "01234");
  if (ref_strspn != 5) {
    *status += 1;
    fprintf(stderr, "sCharSlice_prefixlen2 ref_strspn: %zu expect 5\n", ref_strspn);
  }

  // FIXME more exhaustive tests
}

static void test_sCharSlice_findbytes(int32_t *status) {
  // also compares with strpbrk
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  struct sCharSlice searched_sl = sCharSlice_fromliteral("012345678");
  struct sCharSlice bytes = sCharSlice_fromliteral("73");

  ptrdiff_t res_findbytes = sCharSlice_findbytes(searched_sl, bytes);
  if (res_findbytes != 3) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes1 res: %td expect 3\n", res_findbytes);
  }
  char const *searched_lit1 = "012345678";
  char *ref_strpbrk = strpbrk(searched_lit1, "73");
  if ((size_t)(&ref_strpbrk[0] - &searched_lit1[0]) != 3) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes2 ref_strspn: %zu expect 3\n", strlen(searched_lit1));
  }

  // FIXME more exhaustive tests
}

// TODO compare with strchr
static void test_sCharSlice_findbyte(int32_t *status) {
  struct sCharSlice sl1 = sCharSlice_fromliteral("012345678");
  char const *searched_lit1 = "012345678";
  ptrdiff_t findres = sCharSlice_findbyte(sl1, '1');
  if (findres != 1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbyte1 res: %td expect 1\n", findres);
  }
  char *ref_strchr = strchr(searched_lit1, '1');
  size_t pos = (size_t)(&ref_strchr[0] - &searched_lit1[0]);
  if (pos != 1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes2 ref_strspn: %zu expect 3\n", pos);
  }

  findres = sCharSlice_findbyte(sl1, '8');
  if (findres != 8) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbyte3 res: %td expect 8\n", findres);
  }
  ref_strchr = strchr(searched_lit1, '8');
  pos = (size_t)(&ref_strchr[0] - &searched_lit1[0]);
  if (pos != 8) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes4 ref_strspn: %zu expect 8\n", pos);
  }

  findres = sCharSlice_findbyte(sl1, '9');
  if (findres != -1) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbyte5 res: %td expect -1\n", findres);
  }
  ref_strchr = strchr(searched_lit1, '9');
  if (ref_strchr != NULLPTR) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes6 ref_strspn: not NULLPTR\n");
  }

  findres = sCharSlice_findbyte(sl1, '0');
  if (findres != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbyte7 res: %td expect 0\n", findres);
  }
  ref_strchr = strchr(searched_lit1, '0');
  pos = (size_t)(&ref_strchr[0] - &searched_lit1[0]);
  if (pos != 0) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes8 ref_strspn: %zu expect 0\n", pos);
  }

  findres = sCharSlice_findbyte(sl1, '5');
  if (findres != 5) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbyte9 res: %td expect 5\n", findres);
  }
  ref_strchr = strchr(searched_lit1, '5');
  pos = (size_t)(&ref_strchr[0] - &searched_lit1[0]);
  if (pos != 5) {
    *status += 1;
    fprintf(stderr, "sCharSlice_findbytes10 ref_strspn: %zu expect 5\n", pos);
  }
}

static void test_sCharSlice_reverse_findbyte(int32_t *status) {
  // also compares with strrchr
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);
  (void)status;
  // TODO
}

static void test_sCharSlice_findstring(int32_t *status) {
  // also compareas with strstr
  // TODO
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  struct sCharSlice sl1 = sCharSlice_fromliteral("012345678");

  { // sCharSlice_findstring, strstr
    struct sCharSlice search_str = sCharSlice_fromliteral("90");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromliteral("");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      *status += 1;
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(12) [%s] expect []\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }
  {
    struct sCharSlice search_str = sCharSlice_fromliteral("345");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromliteral("345");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      *status += 1;
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(345) [%s] expect [345]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }
  {
    struct sCharSlice search_str = sCharSlice_fromliteral("012345678");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromliteral("012345678");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      *status += 1;
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(012345678) [%s] expect [012345678]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }
  {
    struct sCharSlice search_str = sCharSlice_fromliteral("12");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromliteral("12");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      *status += 1;
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "2. sCharSlice_findstring(12) [%s] expect [12]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }
  {
    struct sCharSlice search_str = sCharSlice_fromliteral("78");
    struct sCharSlice result_sl = sCharSlice_findstring(sl1, search_str);
    struct sCharSlice expect_sl = sCharSlice_fromliteral("78");
    if (sCharSlice_isEqual(result_sl, expect_sl) != 0) {
      *status += 1;
      memcpy(print_buf, result_sl.ptr, result_sl.len);
      fprintf(stderr, "sCharSlice_findstring1(12) [%s] expect [78]\n", print_buf);
      memset(&print_buf[0], 0, 1024);
    }
  }
}

// strtok (bruh):
// char s[16] = "A,B,C,D";
// char* tok = strtok(s, ",");
// while (tok != NULL) {
//   printf("%s\n", tok);
//   tok = strtok(NULL, ",");
// }
static void test_sCharSlice_tokenize(int32_t *status) {
  char print_buf[1024];
  memset(&print_buf[0], 0, 1024);

  struct sCharSlice sl1 = sCharSlice_fromliteral(";;;;0123;;;45678;;;");
  struct sCharSlice delim1 = sCharSlice_fromliteral(";");
  struct sCharSlice_Interval interv1_1 = sCharSlice_tokenize(sl1, delim1, 0);
  assert(interv1_1.start == 4 && "start 4: ';;;;0'");
  CHECK_EQ(interv1_1.end, 8);
  assert(interv1_1.end == 8 && "end 8: ';;;;0123;'");

  struct sCharSlice_Interval interv1_2 = sCharSlice_tokenize(sl1, delim1, 8);
  assert(interv1_2.start == 11 && "start 11: ';;;;0123;;;4'");
  assert(interv1_2.end == 16 && "end 16: ';;;;0123;;;45678;'");

  struct sCharSlice_Interval interv1_3 = sCharSlice_tokenize(sl1, delim1, 16);
  assert(interv1_3.start == 19 && "start 19: ';;;;0123;;;45678;;;'");
  assert(interv1_3.end == 19 && "end 19: ';;;;0123;;;45678;'");

  struct sCharSlice sl2 = sCharSlice_fromliteral("abc0123abc");
  struct sCharSlice delim2 = sCharSlice_fromliteral("abc");
  struct sCharSlice_Interval interv2_1 = sCharSlice_tokenize(sl2, delim2, 0);
  assert(interv2_1.start == 3 && "start 3: '0123'");
  assert(interv2_1.end == 7 && "end 7: 'abc0123a'");
  struct sCharSlice_Interval interv2_2 = sCharSlice_tokenize(sl2, delim2, 7);
  CHECK_EQ(interv2_2.start, 10);
  assert(interv2_2.start == 10 && "start 10: ''");
  assert(interv2_2.end == 10 && "end 10: ''");

  struct sCharSlice sl3 = sCharSlice_fromliteral("aaa");
  struct sCharSlice delim3 = sCharSlice_fromliteral("a");
  struct sCharSlice_Interval interv3_1 = sCharSlice_tokenize(sl3, delim3, 0);
  CHECK_EQ(interv3_1.start, 3);
  assert(interv3_1.start == 3 && "start 3: ''");
  assert(interv3_1.end == 3 && "end 3: ''");

  struct sCharSlice sl4 = sCharSlice_fromliteral("");
  struct sCharSlice delim4 = sCharSlice_fromliteral("");
  struct sCharSlice_Interval interv4_1 = sCharSlice_tokenize(sl4, delim4, 0);
  assert(interv4_1.start == 0 && "start 0: ''");
  assert(interv4_1.end == 0 && "end 0: ''");

  struct sCharSlice sl5 = sCharSlice_fromliteral("");
  struct sCharSlice delim5 = sCharSlice_fromliteral("a");
  struct sCharSlice_Interval interv5_1 = sCharSlice_tokenize(sl5, delim5, 0);
  assert(interv5_1.start == 0 && "start 0: ''");
  assert(interv5_1.end == 0 && "start 0: ''");

  struct sCharSlice sl6 = sCharSlice_fromliteral("a");
  struct sCharSlice delim6 = sCharSlice_fromliteral("");
  struct sCharSlice_Interval interv6_1 = sCharSlice_tokenize(sl6, delim6, 0);
  CHECK_EQ(interv6_1.start, 0);
  assert(interv6_1.start == 0 && "start 0: 'a'");
  assert(interv6_1.end == 1 && "start 1: 'a'");
  struct sCharSlice_Interval interv7_1 = sCharSlice_tokenize(sl6, delim6, 1);
  assert(interv7_1.start == 1 && "start 1: ''");
  assert(interv7_1.end == 1 && "start 1: ''");
}

int main(void) {

  int32_t status = 0;

  // testing sCharSlice routines
  test_sCharSlice_fromliteral(&status);
  test_sCharSlice_fromcstrbuffer(&status);
  test_sCharSlice_tocstring(&status);
  test_sCharSlice_tocstring_overlapping(&status);
  test_sCharSlice_subslice(&status);
  test_sCharSlice_isEqual(&status);
  test_sCharSlice_concat(&status);
  test_sCharSlice_compare(&status);

  // testing string.h like routines
  test_sCharSlice_nonprefixlen(&status);
  test_sCharSlice_prefixlen(&status);
  test_sCharSlice_findbytes(&status);
  test_sCharSlice_findbyte(&status);
  test_sCharSlice_reverse_findbyte(&status);
  test_sCharSlice_findstring(&status);
  test_sCharSlice_tokenize(&status);

  if (status != 0) {
    fprintf(stderr, "Fail, got %" PRIi32 " errors\n", status);
    return status;
  }

  return 0;
}

#endif
