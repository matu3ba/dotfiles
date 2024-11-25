// TODO flags
// https://learn.microsoft.com/en-us/cpp/cpp/tutorial-import-stl-named-module?view=msvc-170
// https://learn.microsoft.com/en-us/cpp/build/reference/c-cpp-prop-page?view=msvc-170#build-iso-c23-standard-library-modules

#include <cstdint>
#if (__cplusplus >= 202302L)
#define HAS_CPP23 1
static_assert(HAS_CPP23, "use HAS_CPP23 macro");
#endif

int32_t main() { return 0; }
