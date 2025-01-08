// zig cc -std=c11 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./src/slice1.c -o slice1.exe && ./slice1.exe
// zig cc -std=c11 -Werror -Weverything -Wno-unused-macros -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./src/slice1.c -o slice1.exe && ./slice1.exe
// clang -E src/slice1.c
// clang src/slice1.c -o slice.exe && ./slice1.exe

#include <stddef.h> // size_t
#include <stdint.h> // int32_t
#include <string.h>

#define CSTR_SLICE_TYPE(TYPE) \
  struct {                    \
    size_t len;               \
    TYPE *buf;                \
  }

// #define CINTERVAL \
//   struct {        \
//     size_t start; \
//     size_t end;   \
//   }

// clang-format off
// vvvvvvvvvvvvvvvv Modify this to adjust fns + instantiate CSTR_SLICE_DEFINE
#define CSTR_MAP_SLICE_TYPES(F, SEP, ...) \
  F (sslice, char, __VA_ARGS__) SEP       \
  F (islice, int, __VA_ARGS__) SEP        \
  F (uislice, unsigned int, __VA_ARGS__)
#define CSTR_COMMA_SEP() ,

#define CSTR_SLICE_INIT(BUF, LEN) {.buf = (BUF), .len = (LEN)}


#define CSTR_SLICE_GENERATOR_NEW(NAME, TYPE)      \
    __attribute__((always_inline)) inline cstr_##NAME  \
        cstr_new_##NAME(TYPE *buf, size_t len)         \
    {                                                  \
        return (cstr_##NAME)CSTR_SLICE_INIT(buf, len); \
    }

#define CSTR_SLICE_DEFINE(NAME, TYPE)          \
    typedef CSTR_SLICE_TYPE(TYPE) cstr_##NAME; \
    CSTR_SLICE_GENERATOR_NEW(NAME, TYPE)

#define CSTR_DISPATCH_MAP_BASE(STYPE, BTYPE, FUNC) \
  BTYPE * : cstr_##FUNC##_##STYPE
// #define CSTR_DISPATCH_MAP_SLICE(STYPE, BTYPE, FUNC) \
//   cstr_##STYPE : cstr_##FUNC##_##STYPE
#define CSTR_DISPATCH_MAP(STYPE, BTYPE, FUNC, MAP_TYPE) \
  CSTR_DISPATCH_MAP_##MAP_TYPE(STYPE, BTYPE, FUNC)

#define CSTR_DISPATCH_TABLE(FUNC, MAP_TYPE) \
  CSTR_MAP_SLICE_TYPES(CSTR_DISPATCH_MAP, CSTR_COMMA_SEP(), FUNC, MAP_TYPE)

// Dispatch a function based on the type of X
#define CSTR_SLICE_DISPATCH(X, MAP_TYPE, FUNC, ...) \
  _Generic((X), CSTR_DISPATCH_TABLE(FUNC, MAP_TYPE))(__VA_ARGS__)

// Dispatch on base type to call the "new" function with arguments (BUF, LEN)
#define CSTR_SLICE(BUF, LEN) \
    CSTR_SLICE_DISPATCH(BUF, BASE, new, BUF, LEN)
// // Dispatch on slice type to call "alloc_buffer" with argument LEN
// #define CSTR_ALLOC_SLICE_BUFFER(S, LEN) \
//     CSTR_SLICE_DISPATCH(S, SLICE, alloc_buffer, LEN)
// // Dispatch on slice type to index and sub-slice
// #define CSTR_IDX(S, I) \
//     CSTR_SLICE_DISPATCH(S, SLICE, idx, S, I)
// #define CSTR_SUBSLICE(S, I, J) \
//     CSTR_SLICE_DISPATCH(S, SLICE, subslice, S, I, J)
// #define CSTR_PREFIX(S, I) \
//     CSTR_SLICE_DISPATCH(S, SLICE, prefix, S, I)
// #define CSTR_SUFFIX(S, I) \
//     CSTR_SLICE_DISPATCH(S, SLICE, suffix, S, I)
// clang-format on

// typedef CSTR_SLICE_TYPE(char) sslice;
CSTR_SLICE_DEFINE(sslice, char)
CSTR_SLICE_DEFINE(islice, int)
CSTR_SLICE_DEFINE(uislice, unsigned int)

void foo(char *str);
void foo(char *str) {
  cstr_sslice x = CSTR_SLICE_INIT(str, strlen(str));
  (void)x;
  // use x for something
}

int main(void) {
  char c_buf[] = "blabla";
  int i_buf[] = {1, 2, 3};
  (void)c_buf;
  (void)i_buf;

  cstr_sslice x = CSTR_SLICE(c_buf, 42);
  (void)x;
  // islice y = CSTR_SLICE(i_buf, 42);

  return 0;
}
