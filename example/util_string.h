/// String utilities for portable
/// Inspired by https://mailund.dk/posts/cstr-slices/
/// but keep things more explicit at cost of boilerplate.
/// Usage
/// struct sCharSlice sl1 = {.ptr = str_ptr, .len = strlen(str_len)};
/// memcpy(buffer, sl1.ptr, sl1.len);

#pragma once

#include <stddef.h>
#include <stdint.h>

// instead of ssize_t use since C99 existing ptrdiff_t

struct sCharSlice {
  char *ptr;
  size_t len;
};

struct sCharSlice char_subslice(struct sCharSlice s_charslice, size_t start, size_t end);

// returns index starting from s_charslice.ptr + start, -1 on failure
// only range [0,2<<63-1] is supported
ptrdiff_t char_findchar(struct sCharSlice s_charslice, char ch, size_t start, size_t end);

// return slice into buf, empty slice on failure
struct sCharSlice char_findstring(struct sCharSlice buf, struct sCharSlice search);

// returns 0 iff equal, other 1
int32_t isEqual_sCharsSlice(struct sCharSlice s_charslice1, struct sCharSlice s_charslice2);
