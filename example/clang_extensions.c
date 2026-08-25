// zig cc -g -std=c99 -Werror -Weverything -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./example/clang_extensions.c -o ./build/clang_extensions.exe && ./build/clang_extensions.exe
// zig cc -g -std=c11 -Werror -Weverything -Wno-gnu-folding-constant -Wno-gnu-statement-expression-from-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./example/clang_extensions.c -o clang_extensions.exe && ./clang_extensions.exe
// zig cc -g -std=c23 -Werror -Weverything -Wno-gnu-folding-constant -Wno-gnu-statement-expression-from-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./example/clang_extensions.c -o clang_extensions.exe && ./clang_extensions.exe
int main(void) {
  int a = __builtin_elementwise_fshr(1, 2, 3);
  (void)a;
  return 0;
}
