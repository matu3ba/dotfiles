/// String utilities for portable
/// Inspired by https://mailund.dk/posts/cstr-slices/ and Zig,
/// but keep things more explicit at cost of boilerplate.
/// Another motivation is to make string handling sane https://wiki.c2.com/?NonNullTerminatedString
/// Usage
/// struct sCharSlice sl1 = {.ptr = cstr_ptr, .len = strlen(cstr_ptr)};
/// struct sCharSlice sl1 = sCharSlice_fromcstring(str_ptr)
/// or another method
/// memcpy(buffer, sl1.ptr, sl1.len);
/// fwrite(sl1.ptr, sizeof(char), sl1.len, stdout);
/// size_t cstr_len = char_cstringspace(sl1);
/// .. allocate or use buffer of sufficient size ..
/// size_t cstr_written = sCharSlice_tocstring(sl1, &cstr_ptr[0], cstr_len);
/// Do not use string.h methods on 'struct sCharSlice'.

/// Consider using
/// C99 basic string literal check
/// #define IS_STR_LIT(x) (void)((void)(x), &("" x ""))
/// #define MAXSTRLEN_OF_BUF(x) sizeof(x) - 1

// standard memory functions
// search, compare, copy, copy-overlap, set
// memchr, memcmp, memcpy, memmove, memset,
// * memset_s to avoid unwanted compiler optimizations

// -->standard string functions mandate '\0' termination<--
// antipattern locale fns: strcoll, strxfrm
// error code description: strerror
// concat: strcat->strncat, careful: remember to subtract 1 from buffer len!
// * strcat_s neither a fix
// compare: strcmp->strncmp
// copy: strcpy->strncpy, careful: does not add '\0' termination without space
// * strcpy_s neither a fix
// length: strlen
// prefix substring: strcspn (reject), strspn (accept)
// byte set search: strpbrk
// find first/last occurrence of string including '\0': strchr/strrchr
// find first occurrence of string without '\0': strstr
// extract tokens from strings: strtok, strtok_r

#pragma once

#include <stddef.h>
#include <stdint.h>

// instead of ssize_t use since C99 existing ptrdiff_t

// ====sCharSlice routines====

/// len in interval [0, ptrdiff_t] is supported
struct sCharSlice {
  /// pointer to string, which may or may not be '\0' terminated
  /// if unsure, do not use standard string.h functions with this data structure
  char *ptr;
  /// string len excluding '\0' character
  size_t len;
};

/// Interval defined as( [start,end) ], so start inclusive, end exclusive.
struct sCharSlice_Interval {
  size_t start;
  size_t end;
};

/// assume: str_ptr[] is '\0' terminated, for example via
/// string literal like "somestring"
/// When using gcc and clang, __builtin_constant_p is used
/// to ensure that a string literal (always being '\0' terminated)
/// is being used.
/// memcpy(buf1, string_literal, sizeof(string_literal));
/// memset(buf1, 0, sizeof(buf1));
/// correct(good): sCharSlice_fromliteral("some_literal");
/// correct(bad): sCharSlice_fromliteral(&buf[0], sizeof(buf)-1);
struct sCharSlice sCharSlice_fromliteral(char cstr_ptr[]);

/// create sCharSlice from buffer which has string absent of '\0' termination
/// wrong: sCharSlice_frombuffer(&buf[0], sizeof(buf));
/// correct(best): sCharSlice_frombuffer(&buf[0], MAXSTRLEN_OF_BUF(buf));
/// correct(ok): sCharSlice_frombuffer(&buf[0], sizeof(buf)-1);
/// correct(nah): sCharSlice_frombuffer(&buf[0], strlen(buf));
struct sCharSlice sCharSlice_frombuffer(char str_ptr[], size_t str_size_no0term);

/// create sCharSlice from buffer which has string including '\0' termination
/// wrong: sCharSlice_fromcstrbuffer(&buf[0], sizeof(buf)-1);
/// wrong: sCharSlice_fromcstrbuffer(&buf[0], strlen(buf));
/// correct(ok): sCharSlice_fromcstrbuffer(&buf[0], 0);
/// correct(ok): sCharSlice_fromcstrbuffer(&buf[0], sizeof(buf));
struct sCharSlice sCharSlice_fromcstrbuffer(char str_ptr[], size_t str_size_incl0term);

/// write s_char_sl into cstr_ptr and add '\0'-termination
/// cstr_size is usable size for writing
/// returns number of written bytes including '\0'-termination
/// assume: s_char_sl.ptr does not overlap with cstr_ptr
/// assume: s_char_sl.len < 2<<63-1
size_t sCharSlice_tocstring(struct sCharSlice s_char_sl, char cstr_ptr[], size_t cstr_size);

/// write into null-terminated cstr_ptr content of sCharSlice
/// returns number of written bytes including '\0' byte
/// s_char_sl.ptr may overlap with cstr_ptr
size_t sCharSlice_tocstring_overlapping(struct sCharSlice s_char_sl, char cstr_ptr[], size_t cstr_len);

struct sCharSlice sCharSlice_subslice(struct sCharSlice s_char_sl, size_t start, size_t end);

// returns 0 iff equal, otherwise 1
int32_t sCharSlice_isEqual(struct sCharSlice s_char_sl1, struct sCharSlice s_char_sl2);

// ====string.h like routines====

// returns concatenated s_charslice_dest[0..] = [s_char_sl1, s_char_sl]
// or on error 0-range
// better replacement to strcat
// assume: s_charslice_dest does not overlap with s_char_sl1 and s_char_sl2
int32_t sCharSlice_concat(struct sCharSlice *s_charslice_dest, struct sCharSlice s_char_sl1,
                          struct sCharSlice s_char_sl2);

// returns 0 if s1 and s2 equal; -1 if s1 < s2; +1 if s1 > s2
// better replacement to strcmp and strncmp
int32_t sCharSlice_compare(struct sCharSlice s_char_sl1, struct sCharSlice s_char_sl2);

// strcpy is obsolete with memcpy and accessing slice

// returns prefix not in s_char_sl_reject
// better replacement to strcspn
size_t sCharSlice_nonprefixlen(struct sCharSlice s_char_sl, struct sCharSlice s_char_sl_reject);

// returns prefix in s_charslaccept
// better replacement to strspn
size_t sCharSlice_prefixlen(struct sCharSlice s_char_sl, struct sCharSlice s_charslaccept);

// returns index into s_char_sl of first found byte in byte set s_charslbytes
// without match, it returns -1
// assume: s_char_sl.len is in range of ptrdiff_t
// better replacement to strpbrk
ptrdiff_t sCharSlice_findbytes(struct sCharSlice s_char_sl, struct sCharSlice s_charslbytes);

// returns index starting from s_char_sl.ptr + start, -1 on failure
// assume: s_char_sl.len is in range of ptrdiff_t
// better replacement to strchr
ptrdiff_t sCharSlice_findbyte(struct sCharSlice s_char_sl, int ch);

// better replacement to strrchr
ptrdiff_t sCharSlice_reverse_findbyte(struct sCharSlice s_char_sl, int ch);

// return slice into buf, empty slice on failure
// better replacement to strstr
struct sCharSlice sCharSlice_findstring(struct sCharSlice buf, struct sCharSlice search);

// tokenizes s_char_sl, writes token range based on delimiter into token_sl
// returns token_sl.len or 0, if no more token found
// with delimiter = ';' and s_char_sl = [;;;str2;str3]
// writes [str2], returns len str2.len
// better replacement to strtok
// assume: token_sl points into interval specified by s_char_sl
struct sCharSlice_Interval sCharSlice_tokenize(struct sCharSlice s_char_sl, struct sCharSlice delimiter, size_t start);
