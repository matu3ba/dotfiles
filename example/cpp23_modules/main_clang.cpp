// TODO flags
// https://0xstubs.org/using-the-c23-std-module-with-clang-18/
// https://clang.llvm.org/docs/StandardCPlusPlusModules.html

#if (__cplusplus >= 202302L)
#define HAS_CPP23 1
static_assert(HAS_CPP23, "use HAS_CPP23 macro");
#endif
