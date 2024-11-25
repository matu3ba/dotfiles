//! Why clang-tidy should be used.

#include <stdint.h>
#include <stdlib.h>
int string_to_int(char const *num);
void ls(void);
int string_to_int(char const *num) { return atoi(num); }

void ls(void) { system("ls"); }

// clang -Weverything -c why_clang_tidy.c -o build/why_clang_tidy
// clang-tidy -checks='bugprone-*,cert-*,clang-analyzer-*,cppcoreguidelines-*,hicpp-*' why_clang_tidy.c -- -std=c11
//   671 warnings generated.
//   /home/user/dotfiles/example/why_clang_tidy.c:27:10: warning: 'atoi' used to convert a string to an integer value,
//    but function will not report conversion errors; consider using 'strtol' instead [cert-err34-c]
//     return atoi(num);
//            ^
//   /home/user/dotfiles/example/why_clang_tidy.c:31:3: warning: calling 'system' uses a command processor [cert-env33
//   -c]
//     system("ls");
//     ^
//   Suppressed 669 warnings (669 in non-user code).
//   Use -header-filter=.* to display errors from all non-system headers. Use -system-headers to display errors from sy
//   stem headers as well.

#include <stdlib.h>
int32_t main(void) {}
