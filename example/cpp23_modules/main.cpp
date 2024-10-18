// https://0xstubs.org/using-the-c23-std-module-with-clang-18/

#if (__cplusplus >= 202302L)
#define HAS_CPP23 1
static_assert(HAS_CPP23, "use HAS_CPP23 macro");
#endif

// C++23 libstd introduces 2 named modules: std and std.compat
// The former to use std::printf and alike, whereas the latter is for C compat

// compiler imports the entire standard library when you use import std; or
// import std.compat; and does it faster than bringing in a single header file.

// Don't mix and match importing header units and named modules. For example,
// don't import <vector>; and import std; in the same file.

// If you need to use the assert() macro, then #include <assert.h>.
// If you need to use the errno macro, #include <errno.h>.
// Because named modules don't expose macros, this is the workaround if you need
// to check for errors from <math.h>, for example.
//
// Consider using
// numeric_limits<double>::quiet_NaN()
// numeric_limits<double>::infinity()
// std::numeric_limits<int>::min()
// instead of INT_MIN

// https://learn.microsoft.com/en-us/cpp/cpp/tutorial-import-stl-named-module?view=msvc-170
// Named modules don't expose macro definitions or private implementation details.

// https://learn.microsoft.com/en-us/cpp/build/reference/c-cpp-prop-page?view=msvc-170#build-iso-c23-standard-library-modules

// TODO use with clang++
// * figure out sane macro strategy
