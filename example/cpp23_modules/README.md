### Usage

```sh
mkdir -p build_module_example
cmake -G Ninja -S example/cpp23_modules -B build_module_example -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_CXX_FLAGS=-stdlib=libc++
ninja -C build_module_example
build_module_example/modules_clang.exe
```

There is no versioning leading to very poor experience. Stuff may work or
break, if you look at things funny. Looks like clang20 needs gcc15.


### How it works

Named modules don't expose macro definitions or private implementation details.
Do not mix in same module header imports and module imports.

C++23 libstd introduces 2 named modules: std and std.compat
The former to use std::printf and alike, whereas the latter is for C compat

The compiler imports the entire standard library when you use import std; or
import std.compat; and does it faster than bringing in a single header file.

Do not mix and match importing header units and named modules. For example,
do not import `<vector>`; and `import std;` in the same file.

If you need to use the assert() macro, then `#include <assert.h>`.
If you need to use the errno macro, `#include <errno.h>`.
Because named modules don't expose macros, this is the workaround if you need
to check for errors from `<math.h>`, for example.

Consider using
`numeric_limits<double>::quiet_NaN()`
`numeric_limits<double>::infinity()`
`std::numeric_limits<int>::min()`
instead of `INT_MIN`.

Internally, the build system must compute the dependency graph before compiling.

### Examples

1. clang
2. gcc
3. msvc
4. cmake

### Basic module usage

```cppm
module;
// imports
import std;
// exports
export module example;
export namespace example_name {
int ex1() { return 0; }
}
}
```
```cpp
import example;
int main() {
  // int t1 = example_name::test123();
  // (void)t1;
  return 0;
}
```
