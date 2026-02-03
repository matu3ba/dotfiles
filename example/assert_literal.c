// zig cc -g -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/assert_literal.c -o ./build/assert_literal.exe && ./build/assert_literal.exe
// zig cc -g -std=c11 -Werror -Weverything -Wno-gnu-folding-constant -Wno-gnu-statement-expression-from-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./example/assert_literal.c -o assert_literal.exe && ./assert_literal.exe
// zig cc -g -std=c23 -Werror -Weverything -Wno-gnu-folding-constant -Wno-gnu-statement-expression-from-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/assert_literal.c -o assert_literal.exe && ./assert_literal.exe
#include <assert.h>
#include <stdbool.h>
#include <stdlib.h>

#if (__STDC_VERSION__ >= 201112L) // HAS_C11
#define STR(x) STR_(x)
#define STR_(x) #x

#define is_literal(x) ((STR(x))[0] == '"')
#define assert_literal(x) assert(is_literal(x))

// #define static_assert_literal(x) \
//   _Static_assert(_Generic(({ x; }), char *: true, default: false), "not a string literal")
#define static_assert_literal(x)                                                              \
  do {                                                                                        \
    _Static_assert(_Generic(({ x; }), char *: true, default: false), "not a string literal"); \
  } while (false)
#endif

// C99 string literal check
#define IS_STR_LIT(x) (void)((void)(x), &("" x ""))

int main(void) {
  static char const c_programming[] = "c_programming";

#if (__STDC_VERSION__ >= 201112L) // HAS_C11
  assert_literal("c_programming");
  static_assert_literal("c_programming");

  //assert_literal(c_programming);
  //static_assert_literal(c_programming);

  bool is_literal = is_literal("c_programming");
  bool is_not_literal = is_literal(c_programming);
  // (void)is_literal;
  (void)is_not_literal;
  assert(is_literal);
  assert(!is_not_literal);

  static_assert(is_literal("c_programming"), "no literal, but should be one");
  static_assert(is_literal("c_programming"), "literal, but should be none");
#endif

  (void)c_programming;

  // IS_STR_LIT(c_programming);
  IS_STR_LIT("test123");

#if (__STDC_VERSION__ >= 201112L) // HAS_C11
  return is_literal("c_programming") ? EXIT_SUCCESS : EXIT_FAILURE;
  // return is_literal(c_programming) ? EXIT_SUCCESS : EXIT_FAILURE;
#else
  return 0;
#endif
}
