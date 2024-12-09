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
/// size_t cstring_space = char_cstringspace(sl1);
/// char* cstring = char_tocstring(char* str);
/// Do not use string.h methods on 'struct sCharSlice'.

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

struct sCharSlice {
  /// pointer to string, which may or may not be '\0' terminated
  /// if unsure, do not use standard string.h functions with this data structure
  char *ptr;
  /// string len excluding '\0' character
  size_t len;
};

/// assume: str_ptr[] is '\0' terminated, for example via
/// string literal like "somestring"
/// memcpy(buf1, string_literal, sizeof(string_literal));
/// memset(buf1, 0, sizeof(buf1));
struct sCharSlice sCharSlice_fromcstring(char cstr_ptr[]);

/// create sCharSlice from buffer
struct sCharSlice sCharSlice_frombuffer(char str_ptr[], size_t str_len);

/// write into null-terminated cstr_ptr content of sCharSlice
/// returns number of written bytes
/// assume: s_charslice.ptr does not overlap with cstr_ptr
/// assume: s_charslice.len < 2<<63-1
size_t sCharSlice_tocstring(struct sCharSlice s_charslice, char cstr_ptr[], size_t cstr_len);

/// write into null-terminated cstr_ptr content of sCharSlice
/// returns number of written bytes including '\0' byte
/// s_charslice.ptr may overlap with cstr_ptr
size_t sCharSlice_tocstring_overlapping(struct sCharSlice s_charslice, char cstr_ptr[], size_t cstr_len);

struct sCharSlice sCharSlice_subslice(struct sCharSlice s_charslice, size_t start, size_t end);

// returns 0 iff equal, otherwise 1
int32_t sCharSlice_isEqual(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2);

// ====string.h like routines====

// returns concatenated s_charslice_dest[0..] = [s_charslice1, s_charslice]
// or on error 0-range
// better replacement to strcat
// assume: s_charslice_dest does not overlap with s_charslice1 and s_charslice2
int32_t sCharSlice_concat(struct sCharSlice *s_charslice_dest, struct sCharSlice s_charslice1,
                          struct sCharSlice s_charslice2);

// returns 0 if s1 and s2 equal; -1 if s1 < s2; +1 if s1 > s2
// better replacement to strcmp and strncmp
int32_t sCharSlice_compare(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2);

// strcpy is obsolete with memcpy and accessing slice

// returns prefix not in s_charslreject
// better replacement to strcspn
size_t sCharSlice_nonprefixlen(struct sCharSlice s_charslice, struct sCharSlice s_charslreject);

// returns prefix in s_charslaccept
// better replacement to strspn
size_t sCharSlice_prefixlen(struct sCharSlice s_charslice, struct sCharSlice s_charslaccept);

// returns index into s_charslice of first found byte in byte set s_charslbytes
// without match, it returns -1
// assume: s_charslice.len is in range of ptrdiff_t
// better replacement to strpbrk
ptrdiff_t sCharSlice_findbytes(struct sCharSlice s_charslice, struct sCharSlice s_charslbytes);

// returns index starting from s_charslice.ptr + start, -1 on failure
// assume: s_charslice.len is in range of ptrdiff_t
// better replacement to strchr
ptrdiff_t sCharSlice_findbyte(struct sCharSlice s_charslice, int ch);

// better replacement to strrchr
ptrdiff_t sCharSlice_reverse_findbyte(struct sCharSlice s_charslice, int ch);

// return slice into buf, empty slice on failure
// better replacement to strstr
struct sCharSlice sCharSlice_findstring(struct sCharSlice buf, struct sCharSlice search);

// tokenizes s_charslice to get next token range based on delimiter
// with delimiter = ';' and s_charslice = [;;;str2;str3] -> returns [str2]
// or empty string without result
// better replacement to strtok
struct sCharSlice sCharSlice_tokenize(struct sCharSlice s_charslice, struct sCharSlice delimiter);
