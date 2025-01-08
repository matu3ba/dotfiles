// https://0xstubs.org/using-the-c23-std-module-with-clang-18/
// https://clang.llvm.org/docs/StandardCPlusPlusModules.html
// https://libcxx.llvm.org/Modules.html
// https://clang.llvm.org/docs/Modules.html

import std; // When importing std.compat it's not needed to import std.
import std.compat;

int main() {
  std::print("Hello modular world\n");
  ::printf("Hello compat modular world\n");
}
