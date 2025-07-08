/// Tested with
/// clang -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default example/operator_precedence.c
/// clang -std=c11 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat example/operator_precedence.c
/// clang -std=c17 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat example/operator_precedence.c
/// clang -std=c23 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c23-compat example/operator_precedence.c
/// clang -O0 -std=c99 example/operator_precedence.c && ./a.out
/// gcc -O0 -std=c99 example/operator_precedence.c && ./a.out
/// zig cc -O0 -std=c99 example/operator_precedence.c && ./a.out
/// clang -O3 -std=c99 example/operator_precedence.c && ./a.out
/// gcc -O3 -std=c99 example/operator_precedence.c && ./a.out
/// zig cc -O3 -std=c99 example/operator_precedence.c && ./a.out
/// clang -O0 -std=c23 example/operator_precedence.c && ./a.out
/// gcc -O0 -std=c23 example/operator_precedence.c && ./a.out
/// zig cc -O0 -std=c23 example/operator_precedence.c && ./a.out
/// clang -O3 -std=c23 example/operator_precedence.c && ./a.out
/// gcc -O3 -std=c23 example/operator_precedence.c && ./a.out
/// zig cc -O3 -std=c23 example/operator_precedence.c && ./a.out

#include <stdint.h>
#include <stdio.h>
int main(void) {
  {
    // The evaluation order in this example is ambiguous, because both operators
    // () and ++ have identical precedence and associativity only describes
    // evaluation in case of conflicts.
    int32_t var = 0;
    int32_t *ptr_var = &var;
    int32_t res = (*ptr_var)++;
    printf("(*ptr_var)++ %d var %d\n", res, var);
  }
  {
    int32_t var = 0;
    int32_t *ptr_var = &var;
    int32_t res = *(ptr_var++);
    printf("*(ptr_var++) %d var %d\n", res, var);
  }
  return 0;
}
