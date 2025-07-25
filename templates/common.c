#if (__STDC_VERSION__ < 199901L)
#error "requires C99 for sanity"
#endif

//====tldr;
// string handling with C standard functions is error prone, absence of hashing
// annoying and then there is no reliable enough clangd strict mode or other fast
// analyzer to prevent type issues and unhandled cases without pile of false
// positives due to too few control over the to be used algebra.
//
// Missing alignment in type system and language allowing stack spills left and
// right is the cherry on top.
// So while later C standards describe no family of simple bootstrappable
// languages, they provide not sufficient strictness to write reliably high
// performance code in fundamental unsafe areas either. This starts with no type
// safe way to format strings.

//! Tested with
//! zig cc -std=c99 -Werror -Weverything -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default ./templates/common.c -o commonc99.exe && ./commonc99.exe
//! zig cc -std=c11 -Werror -Weverything -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./templates/common.c -o commonc11.exe && ./commonc11.exe
//! zig cc -std=c17 -Werror -Weverything -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-pre-c11-compat ./templates/common.c -o commonc17.exe && ./commonc17.exe
//! zig cc -std=c23 -Werror -Weverything -Wno-disabled-macro-expansion -Wno-unsafe-buffer-usage -Wno-declaration-after-statement -Wno-switch-default -Wno-c++98-compat -Wno-pre-c11-compat -Wno-pre-c23-compat ./templates/common.c -o commonc23.exe && ./commonc23.exe
#include <assert.h>
#include <stdint.h>

//====hacks
// "exceptions" https://gist.github.com/mlugg/eea73b7795d2282ca5d6d825e67c5f07
// * beware that setjmp and longjmp dont clean up anything and do straight jumps

// TODO write examples pkg-config flags for compilation based on https://ariadne.space/2025/02/08/c-sboms-and-how-pkgconf.html
// gcc -o main main.c `pkg-config --cflags --libs glib-2.0`
// see C SBOMs

//====tldr;
// string handling with C standard functions is error prone, absence of hashing
// annoying and then there is no reliable enough clangd strict mode or other fast
// analyzer to prevent type issues and unhandled cases without pile of false
// positives due to too few control over the to be used algebra.
//
// Missing alignment in type system and language allowing stack spills left and
// right is the cherry on top.
// So while later C standards describe no family of simple bootstrappable
// languages, they provide not sufficient strictness to write reliably high
// performance code in fundamental unsafe areas either. This starts with no type
// safe way to format strings.

// ugly rules initialization rules:
// 1. struct stat x = { .field = 7 };
//    without empty initializer padding and various union members can be left uninitialized
//    workaround: -fzero-init-padding-bits=all

// TODO list
// GNU function attributes and storage class information
// function attributes
// C99
// * TODO ..
// C23
// * [[deprecated]]
// * [[fallthrough]]
// * [[maybe_unused]]
// * [[nodiscard]]
// * [[noreturn]]
// * [[reproducible]]
// * [[unsequenced]]
#if (__STDC_VERSION__ >= 199901L)
#define HAS_C99 1
#endif // (__STDC_VERSION__ >= 199901L)
#if (__STDC_VERSION__ >= 201112L)
#define HAS_C11 1
static_assert(HAS_C11, "use HAS_C11 macro");
#endif // (__STDC_VERSION__ >= 201112L)
#if (__STDC_VERSION__ >= 201710L)
#define HAS_C17 1
static_assert(HAS_C17, "use HAS_C17 macro");
#endif // (__STDC_VERSION__ >= 201710L)
#if (__STDC_VERSION__ >= 202311L)
#define HAS_C23 1
static_assert(HAS_C23, "use HAS_C23 macro");
#endif // (__STDC_VERSION__ >= 202311L)
#if !defined(HAS_C99)
#error "requires C99 for sanity"
#endif // !defined(HAS_C99)

// null ptr compat
#if defined(HAS_C23)
#define NULLPTR nullptr
#else // !defined(HAS_C23)
#if (defined(_MSC_VER) || defined(__cplusplus))
#define NULLPTR 0
#else // !(defined(_MSC_VER) || defined(__cplusplus))
#define NULLPTR ((void *)0)
#endif // (defined(_MSC_VER) || defined(__cplusplus))
#endif // defined(HAS_C23)

#include <errno.h>    // errno
#include <inttypes.h> // PRIXPTR and other portable printf formatter
#include <limits.h>   // limit
#if defined(_WIN32)
#include <malloc.h> // not standard conform in stdlib.h and fn names with _ prefix
#endif              // defined(_WIN32)
#include <math.h>   // INFINITY
#include <stddef.h>
#include <stdint.h> // uint32_t, uint8_t
#include <stdio.h>  // fprintf, fseek, FILE
#include <stdlib.h> // exit
#include <string.h> // memcpy

// Keep -Weverything happy
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//====tooling
//====version
//====macros
//====lto
//====pointers
//====encoding
//====signaling_unix
//====signaling_win
//====printf_formatter

// best practice compilation time
// * https://codingnest.com/the-little-things-speeding-up-c-compilation/
//   - include less, ideally IWYU https://include-what-you-use.org/
//   - forward decls
// * sccache https://github.com/mozilla/sccache
// * avoid macros and macro nesting and macro deps, if possible
// https://interrupt.memfault.com/blog/improving-compilation-times-c-cpp-projects

// best practice resource handling
// * Simple options for handling resource R
//   - 1. Either R is acquired and released in main
//   - 2. main allocates N instances of R, the rest of the code explicitly juggles this finite pool of N.
//     This juggling typically doesn't involve memory managing at all, as, at this level of precision, so you only code the happy path
//   - 3. some sort of arena, where a bunch of resources have a single owner, users dont bother cleaning
//     up their resources, and instead the owner does it once at the end
// * defer pattern with jump labels

// best practice compile time checks
// * macro hacks like these for static_assert https://stackoverflow.com/questions/3385515/static-assert-in-c
// * compiler builtins
// * static_assert with C11: _Static_assert (0, "assert1");
// * constexpr in C23

// SHENNANIGAN __builtin_constant_p does not check for string literals

#if defined(HAS_C23)
static_assert((2 + 2) % 3 == 1, "Whoa dude, you knew!");
#define outscope_assert(expr) static_assert(expr, "")
outscope_assert((2 + 2) % 3 == 1);
#define comptime_assert(expr, msg) static_assert(expr, msg)
comptime_assert((2 + 2) % 3 == 1, "Whoa dude, you knew!");
#elif defined(HAS_C11)
_Static_assert(2 + 2 * 2 == 6, "Lucky guess!?");
#define outscope_assert(expr) _Static_assert(expr, "")
outscope_assert(2 + 2 * 2 == 6);
#define comptime_assert(expr, msg) _Static_assert(expr, msg)
comptime_assert((2 + 2) % 3 == 1, "Whoa dude, you knew!");
#else // (!defined(HAS_C23) && !defined(HAS_C11))
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wmissing-variable-declarations"
#define CONCAT_(prefix, suffix) prefix##suffix
#define CONCAT(prefix, suffix) CONCAT_(prefix, suffix)
#define outscope_assert(expr)                      \
  struct CONCAT(outscope_assert___, __COUNTER__) { \
    char outscope_assert[2 * (expr) - 1];          \
                                                   \
  } CONCAT(outscope_assert___, __COUNTER__)
#define inscope_assert(expr)             \
  do {                                   \
    char inscope_assert[2 * (expr) - 1]; \
    (void)inscope_assert;                \
  } while (0)
#define comptime_assert(expr, msg) outscope_assert(expr)
outscope_assert(1 < 2);
comptime_assert(1 < 2, "");
void prevent_error(void);
void prevent_error(void) {
  char buf[10];
  outscope_assert(2 + 2 * 2 == 6);
  outscope_assert(sizeof(buf) == 10);
  comptime_assert(1 < 2, "unused");
  inscope_assert(sizeof(buf) == 10);
}
#pragma clang diagnostic pop
#endif // defined(HAS_C23), defined(HAS_C11), else

int32_t defer_in_c(void);
int32_t defer_in_c(void) {
  int32_t st = 0;

  int32_t *var1 = malloc(sizeof(int32_t));
  *var1 = 10;
  int32_t wr_st1 = fprintf(stdout, "var1: %" PRIi32 "\n", *var1);
  if (wr_st1 <= 0) {
    st = 1;
    goto DEFER_CLEANUP1;
  }

  int32_t *var2 = malloc(sizeof(int32_t));
  *var2 = 20;
  int32_t wr_st2 = fprintf(stdout, "var1: %" PRIi32 "\n", *var1);
  if (wr_st2 <= 0) {
    st = 1;
    goto DEFER_CLEANUP2;
  }

DEFER_CLEANUP2:
  free(var2);
DEFER_CLEANUP1:
  free(var1);

  return st;
}
// * errdefer pattern with jump labels
int32_t *errdefer_in_c(void);
int32_t *errdefer_in_c(void) {
  int32_t st = 0;
  int32_t *var1 = malloc(sizeof(int32_t));
  *var1 = 10;
  int32_t wr_st1 = fprintf(stdout, "var1: %" PRIi32 "\n", *var1);
  if (wr_st1 <= 0) {
    goto ERRDEFER_CLEANUP1;
  }

  int32_t *var2 = malloc(sizeof(int32_t));
  *var2 = 30;
  int32_t wr_st2 = fprintf(stdout, "var1: %" PRIi32 "\n", *var1);
  if (wr_st2 <= 0) {
    st = 1;
    goto DEFER_CLEANUP2;
  }

DEFER_CLEANUP2:
  free(var2);

  if (st == 0)
    return var1;

ERRDEFER_CLEANUP1:
  free(var1);

  return NULLPTR;
}

//====tooling
// cerberus
// clang-tidy
// cppcheck
// frama-c
// DWARF and ELF verified spec impl + model usable as test oracle https://github.com/rems-project/linksem
// psyche-e incomplete file completer and compiler https://github.com/ltcmelo/psychec http://cuda.dcc.ufmg.br/psyche-c/
// clang -fsanitize=address -g -O1 -fno-omit-frame-pointer main.cpp
// * wiki with info
// * 2x slowdown, increased binary size, needs build system support
// * maps lots of virtual memory
// * only as good as coverage
// * ASan, UBSan, LSan, TSan, MSan
// no zero-runtime cost type-safe printf possible without adding more powerful
// meta-programming (or stack-based macros for iterating),
// see https://github.com/moehriegitt/vastringify

// string handling https://github.com/skullchap/chadstr
// 2d ui layout library https://github.com/nicbarker/clay

// standard memory functions
// search, compare, copy, copy-overlap, set
// memchr, memcmp, memcpy, memmove, memset,
// * memset_s to avoid unwanted compiler optimizations

// -->standard string functions mandate '\0' termination<--
// antipattern locale fns: strcoll, strxfrm
// error code description: strerror
// concat: strcat->strncat, careful: remember to subtract 1 from buffer len!
// * strcat_s neither a fix
// compare: strcmp->strncmp
// copy: strcpy->strncpy, careful: does not add '\0' termination without space
// * strcpy_s neither a fix
// length: strlen
// prefix substring: strcspn (reject), strspn (accept)
// byte set search: strpbrk
// find first/last occurrence of string including '\0': strchr/strrchr
// find first occurrence of string without '\0': strstr
// extract tokens from strings: strtok, strtok_r

// makefile that builds GCC cross-toolchains for many archs https://github.com/vezel-dev/kruco

//====version
// setting iso version:
// clang4  -std=c89
// clang4  -std=c99
// clang4  -std=c11
// clang6  -std=c17
// clang18 -std=c23

// ====macros
// http://scaryreasoner.wordpress.com/2009/02/28/checking-sizeof-at-compile-time/
// #define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2 * !!(condition)]))
// Stuck with C90, better use assert or static_assert
// uint8_t const var0 = 0;
// uint8_t const var2 = 0;
// #define BUILD_BUG_ON_ZERO(e) ((int)(sizeof(struct { int : (-!!(e)); })))
// #define WTF BUILD_BUG_ON_ZERO(0)
// usage: #define MACRO (BUILD_BUG_ON( sizeof(someThing) != PAGE_SIZE ));
// #define CHECKED_MACRO_VAR0(w) (BUILD_BUG_ON(var0))
// #define CHECKED_MACRO_VAR2(w) (BUILD_BUG_ON(var2))

// dump macro definitions
// echo common.h  | clang -E -dM -

//====lto
// # Compile and link. Select regular LTO at link time.
// clang -flto -funified-lto -fuse-ld=lld foo.c
// # Compile and link. Select ThinLTO at link time.
// clang -flto=thin -funified-lto -fuse-ld=lld foo.c
// # Link separately, using ThinLTO.
// clang -c -flto -funified-lto foo.c  # -flto={full,thin} are identical in
// terms of compilation actions
// clang -flto=thin -fuse-ld=lld foo.o  # pass --lto=thin to ld.lld
// # Link separately, using regular LTO.
// clang -c -flto -funified-lto foo.c
// clang -flto -fuse-ld=lld foo.o  # pass --lto=full to ld.lld

// meta lang, algebraic data types, interfaces for C99
// https://github.com/Hirrolot/metalang99, https://github.com/Hirrolot/datatype99, https://github.com/Hirrolot/interface99
// compiler C abi checks
// https://github.com/Gankra/abi-cafe

// Debugging with cosmopolitcan libc
// https://ahgamut.github.io/2022/10/23/debugging-c-with-cosmo/

// Standards
// http://port70.net/~nsz/c/

// Design of C: I refuse to believe C had any design other than compiler impl
// worksforme and which hackfix can be applied.

//====pointers
// SHENNANIGAN
// In short: Pointers are a huge footgun in C standard.
// See https://matu3ba.github.io/post/shennanigans_in_c.html
//
// - The safe to have no miscompilations fix for access a pointer with increased
// alignment is to use a temporary with memcopy
// - To only compare pointers decrease alignment with char* pointer.
// - To prune type info for generics use void* pointer.
// You are responsible to call a function that provides or provide yourself
// - 1. proper alignment,
// - 2. sufficient storage and
// - 3. if nececssary sufficient padding (ie within structs),
// - 4. correct aliasing.
// "Strict Aliasing Rule"
// C23 6.5 Expressions paragraph 7
// "An object shall have its stored value accessed only by an lvalue expression
// that has one of the following types - a type compatible with the effective type of the object,
// - a qualified version of a type compatible with the effective type of the object,
// - a type that is the signed or unsigned type corresponding to the effective type of the object,
// - a type that is the signed or unsigned type corresponding to a qualified version of the effective type of the object,
// - an aggregate or union type that includes one of the aforementioned types among its members (including, recursively, a member of a subaggregate or contained union), or
// - a character type."
// => assume: Access upholds (&array[0] <= ptr && ptr < &array[len+1])

// bound check annotations https://clang.llvm.org/docs/BoundsSafety.html
// * -fbounds-safety
// * int32_t * __counted_by(N) ptr_name
// * __single is default annotation for visible ptrs
// * __counted_by: ptr points to N elems of pointee type,
// * __sized_by: ptr points to memory that contain N bytes
// * __ended_by: final ptr value not allowed to be dereferenced
struct wide_pointer_datalayout {
  void *pointer;     // Address used for dereferences and pointer arithmetic
  void *upper_bound; // Points one past the highest address that can be accessed
  void *lower_bound; // (Optional) Points to lowest address that can be accessed
};
// * without annotation local pointer variable is implicitly __bidi_indexable
// * otherwise use __indexable for no explicit lower bound
// * C strings are implicitly __null_terminated as special case of __terminated_by(T)
// * __unsafe_terminated_by_to_indexable(P, T), __unsafe_null_terminated_to_indexable(P) to convert
// __terminated_by pointer P to an __indexable pointer
// * __unsafe_indexable behave like plain C pointers, typically used for ptrs by system code
// * __unsafe_terminated_by_from_indexable(T, PTR [, PTR_TO_TERM])
// * __unsafe_forge_terminated_by(T, P, E)

#if defined(__clang__) && defined(HAS_C23)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wbuiltin-macro-redefined"
#pragma clang diagnostic ignored "-Wmacro-redefined"
#pragma clang diagnostic ignored "-Wreserved-identifier"
#if (defined(__has_feature) && __has_feature(bounds_safety))
#define __counted_by(T) __attribute__((__counted_by__(T)))
// ... other bounds annotations
#else                   // !(defined(__has_feature) && __has_feature(bounds_safety))
#define __counted_by(T) // defined as nothing
// ... other bounds annotations
#endif
#pragma clang diagnostic pop
#endif // (defined(__clang__) && defined(HAS_C23))

#if (defined(__clang__) && defined(HAS_C23))
size_t use_counted_by(char *__counted_by(len) ptr, size_t len);
size_t use_counted_by(char *__counted_by(len) ptr, size_t len) {
  size_t str_len = 0;
  for (size_t i = 0; i < len; i += 1) {
    if (ptr[i] == 0)
      break;
    str_len += 1;
  }
  return str_len;
}
#endif // (defined(__clang__) && defined(HAS_C23))

// https://faultlore.com/blah/tower-of-weakenings/#the-tower-of-weakenings
// https://lwn.net/Articles/990273/
// https://www.cs.cornell.edu/courses/cs6120/2019fa/blog/tbaa/
// idea explain typed based aliasing analysis

// Exceptions:
// - posix extension/Windows: casting pointers to functions (and back) also use for dynamic linking etc
// - clang and gcc have -fno-strict-aliasing, msvc and tcc do disable type-based aliasing analysis based optimizations
// - no switch to disable provenance-based alias analysis in compilers (clang, gcc, msvc, tcc)
// - Usage of restrict can be en/disabled in all compilers via #pragma optimize("", on/off).
//   It can also be disabled in all compilers via #define restrict, using an according optimization level (typical -O1)
//   or via separating header and implementation and disabling link time optimziations.

// SHENNANIGAN memset_s and other *_s fns are optional, have heavy cost
// without benefit and C23 got instead memset_explicit.
// clangd still complains
// some features of memset_s that memset lacks (hence many platforms/libcs are
// not implementing the routines):
// * null pointer check on the destination array
// * only partial sanity check on the block size
// * memset_s() can not be elided: K.3.7.4.1
// nevertheless Checks: "-clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling"
// is needed and

// Inherently racy, so do not use, if possible. The stat call is also faster,
// but this demonstrates how to poke and peek through a file.
size_t getFileSize(char const *file_path);
size_t getFileSize(char const *file_path) {
  FILE *file = NULLPTR;
  file = fopen(file_path, "rb");
  if (file == NULLPTR)
    exit(1); // could not open file, better use file handle
  (void)fseek(file, 0u, SEEK_END);
  long file_size_or_err = ftell(file);
  if (file_size_or_err < 0)
    exit(1); // invalid file size
  (void)fseek(file, 0u, SEEK_SET);
  (void)fclose(file);
  return (size_t)file_size_or_err;
}

static void memset_16aligned(void *ptr, char byte, size_t size_bytes, uint16_t alignment) {
  assert((size_bytes & (alignment - 1)) == 0);     // Size aligned
  assert(((uintptr_t)ptr & (alignment - 1)) == 0); // Pointer aligned
  // #if defined(HAS_C23)
  // // make sensitive information stored in the object inaccessible
  //   memset_explicit(ptr, byte, size_bytes);
  // #else // !defined(HAS_C23)
  memset(ptr, byte, size_bytes);
  // #endif // defined(HAS_C23)
}
// 1. Careful with segmented address spaces: lookup uintptr_t semantics
// 2. Careful with long standing existing optimization compiler bugs pointer to
// integer and back optimizations in for example clang and gcc
// 3. Careful with LTO potentially creating problem 2. (clang -flto -funified-lto -fuse-ld=lld ptrtoint_inttoptr.c)
// 4. Consider C11 aligned_alloc or posix_memalign
int32_t ptrtointtoptr(void);
int32_t ptrtointtoptr(void) {
  uint16_t const alignment = 16;
  uint16_t const align_min_1 = alignment - 1;
  void *mem = malloc(1024 + align_min_1);
  if (mem == NULLPTR)
    return 1;
  // C89: void *ptr = (void *)(((INT_WITH_PTR_SIZE)mem+align_min_1) & ~(INT_WITH_PTR_SIZE)align_min_1);
  // ie void *ptr = (void *)(((uint64_t)mem+align_min_1) & ~(uint64_t)align_min_1);
  // offset ptr to next alignment byte boundary
  void *ptr = (void *)(((uintptr_t)mem + align_min_1) & ~(uintptr_t)align_min_1);
  printf("0x%08" PRIXPTR ", 0x%08" PRIXPTR "\n", (uintptr_t)mem, (uintptr_t)ptr);
  memset_16aligned(ptr, 0, 1024, alignment);
  free(mem);
  return 0;
}

// macro NULL = 0 or mingw null

void assert_with_text(void);
void assert_with_text(void) { assert((1 == 1) && "sometext"); }

void standard_namespacing(void);
void standard_namespacing(void) {
  // Standard enum, struct etc
  struct Namespace1 {
    // unscoped enum place fields into outest file scope
    enum Mode {
      Undefined,
      Mode1,
      Mode2,
    } eMode;
    char _pad1[60];

    union Repr {
      uint64_t u64;
      struct Splu64 {
        uint32_t higher;
        uint32_t lower;
      } sSplu64;
    } uRepr;
  } sNamespace1;
  // struct Namespace1 sNamespace1;
  union Repr U64;
  U64.u64 = 12;
  sNamespace1.eMode = Undefined;
  sNamespace1.uRepr.u64 = 12;
#if defined(HAS_C11)
  static_assert(sizeof(sNamespace1.eMode) == 4, "eMode has no size of 4 byte");
#endif // defined(HAS_C11)

  switch (sNamespace1.eMode) {
    case Undefined:
      break;
    case Mode1:
      break;
    case Mode2:
      break;
  }
}

void c_enum_in_struct_weirdness(void);
void c_enum_in_struct_weirdness(void) {
  uint32_t const device_type = 1;
  struct BeckhoffDeviceType {
    enum Ty {
      Undefined = 0,
      EK1100,
      EL1008,
      EL2008,
      EL5151,
      Max,
    } ty;
  };
  struct BeckhoffDeviceType devty;
  devty.ty = device_type;
}

void cpp_namespaces_enums_in_structs(int32_t device_type);
void cpp_namespaces_enums_in_structs(int32_t device_type) {
  (void)device_type;
  struct BeckhoffDeviceType {
    enum Ty {
      Undefined = 0,
      EK1100,
      EL1008,
      EL2008,
      EL5151,
      Max,
    } ty;
  };
  struct BeckhoffDeviceType devty;
  (void)devty;
  // c compiler: Use of undeclared identifier 'BeckhoffDeviceType'
  // cpp compiler: works fine and might be needed
  // devty.ty = (BeckhoffDeviceType.Ty)device_type;
}

int32_t c_enum(uint32_t in);
int32_t c_enum(uint32_t in) {
  enum Example {
    EX0 = 0,
    EX1,
  };
#if defined(HAS_C11)
  static_assert(sizeof(enum Example) == 4, "eMode has no size of 4 byte");
#endif // defined(HAS_C11)
  enum Example ex = in;
  switch (ex) {
    case EX0: {
      return 0;
      // break;
    }
    case EX1: {
      return 1;
      // break;
    }
  }
}

// getting enum strings is related to https://stackoverflow.com/questions/18070763/get-enum-value-by-name

// Superfluous with C23.
#if !defined(GENERATE_ENUM_STRINGS)
#define DECL_ENUM_ELEMENT(element) element
#define BEGIN_ENUM(ENUM_NAME) typedef enum tag##ENUM_NAME
#define END_ENUM(ENUM_NAME) \
  ENUM_NAME;                \
  char *getString##ENUM_NAME(enum tag##ENUM_NAME index);
#else // defined(GENERATE_ENUM_STRINGS)
#define DECL_ENUM_ELEMENT(element) #element
#define BEGIN_ENUM(ENUM_NAME) char *gs_##ENUM_NAME[] =
#define END_ENUM(ENUM_NAME) \
  ;                         \
  char *getString##ENUM_NAME(enum tag##ENUM_NAME index) { return gs_##ENUM_NAME[index]; }
#endif // !defined(GENERATE_ENUM_STRINGS)
// enum definition
BEGIN_ENUM(OsType){
    DECL_ENUM_ELEMENT(WINBLOWS),
    DECL_ENUM_ELEMENT(HACKINTOSH),
} END_ENUM(OsType)
    // usage
    // getStringOsType(WINBLOWS);

    inline void hash_combine(unsigned long *seed, unsigned long const value);
/// taken from boost hash_combine, only ok for <10% of used range, optimized for performance
inline void hash_combine(unsigned long *seed, unsigned long const value) {
  *seed ^= value + 0x9e3779b9 + (*seed << 6) + (*seed >> 2);
}

// https://github.com/tidwall/th64
// looks like it is not includede in smhasher3 and does not look tiny
// inline uint64_t th64(void *data, size_t len, uint64_t seed) {
//     //warning: unsafe pointer arithmetic [-Wunsafe-buffer-usage]
//     // 294 |     uint8_t*p = (uint8_t*)data, *e = p+len;
//     //                                            ^
//     // uint8_t*p = (uint8_t*)data, *e = p+len;
//     uint8_t*p = (uint8_t*)data, *e = p+len;
//     uint64_t r = 0x14020a57acced8b7, x, h=seed;
//     while(p+8 <= e)
//       (void)memcpy(&x, p, 8), (void)(x*=r), (void)(p+=8), (void)(x=x<<31|x>>33), (void)(h=h*r^x), (void)(h=h<<31|h>>33);
//     while(p<e)
//       h = h*r^*(p++);
//     return((void)(h = h*r+len), (void)(h ^= h>>31), (void)(h *= r), (void)(h ^= h>>31), (void)(h *= r), (void)(h ^= h>>31), (void)(h *= r), h);
// }

// idea siphash for better performance
// https://gitlab.com/fwojcik/smhasher3
// https://github.com/rui314/mold/commit/fa8e95a289f911c0c47409d5848c993cb50c8862

// SHENNANIGAN clang has useless warnings firing on trivial code like
// templates\common.c:315:7: warning: unsafe pointer arithmetic [-Wunsafe-buffer-usage]
//   315 |       tmps++;
//       |       ^~~~

int32_t Str_Len(char const *str);
/// assume: continuous data pointed to by str is terminated with 0x00
int32_t Str_Len(char const *str) {
  if (str == NULLPTR)
    return 0;
  char const *tmps = str;
  while (*tmps != 0)
    tmps++;
  return (int32_t)(tmps - str);
}

void Str_Copy(char const *str, int32_t strlen, char *str2);
/// assume: continuous data pointed by input str terminated with 0x00
/// assume: str2 has sufficient backed memory size
/// copy strlen chars from str to str2
void Str_Copy(char const *str, int32_t strlen, char *str2) {
  for (int i = 0; i < strlen; i += 1)
    str2[i] = str[i];
}

int32_t Int_CeilDiv(int32_t x, int32_t y);
/// assume: positive number
/// assume: x + y does not overflow
/// computes x/y
int32_t Int_CeilDiv(int32_t x, int32_t y) { return (x + y - 1) / y; }

// byte-wise dumping somewhat pretty compatible with strlen
// inline void dumpMemory(const char * memory, size_t size);
static inline void dumpMemory(char const *memory, size_t size) {
  if (memory == NULLPTR)
    return;
  uint32_t cols = 80;
  for (uint32_t i = 0; i < size; i += 1) {
    fprintf(stdout, "%x ", memory[i]);
    if ((cols + 1) % 2 == 0)
      fprintf(stdout, " ");
    if (cols % cols == 0)
      fprintf(stdout, "\n");
  }
}

void use_dumpMemory(void);
void use_dumpMemory(void) {
  char const *some_memory = "some_memory";
  dumpMemory(some_memory, strlen(some_memory));

  // options for lower aligned pointers
  // 1. copy around memory etc to get lower aligned pointer to memory
  // 2. copy pointers to print memory
}

void printBits(int32_t const size, void *const ptr);
// assume: little endian
void printBits(int32_t const size, void *const ptr) {
  if (ptr == NULLPTR)
    return;
  int status = 0;
  unsigned char *b = (unsigned char *)ptr; // generic pointer (void)
  for (int32_t i = size - 1; i >= 0; i -= 1) {
    for (int32_t j = 7; j >= 0; j -= 1) {
      unsigned char byte = (b[i] >> j) & 1; // shift ->, rightmost bit
      status = printf("%u", byte);
      if (status < 0)
        abort(); // stdlib.h
    }
    status = printf("%x", b[i]);
    if (status < 0)
      abort();
  }
  //printf(" ");
  status = puts(""); // write empty string followed by newline
  if (status < 0)
    abort();
}

void print_size_t(void);
void print_size_t(void) {
  // SHENNANIGAN clangd: no autocorrection of printf formatter string
  size_t val_size_t = 0;
  printf("%zu\n", val_size_t);
  ptrdiff_t val_ptrdiff_t = 0;
  printf("%td\n", val_ptrdiff_t);

  uint32_t val_uint32_t = 0;
  printf("%" PRIu32 "\n", val_uint32_t);
  int32_t val_int32_t = 0;
  printf("%" PRId32 "\n", val_int32_t);
}

// easy preventable ub:
// - unhandled enum case: flag

// Composable annotations for verification with separation logic for pointer
// semantics, which requires minimal user input and produces Coq proofs.
// "RefinedC: Automating the Foundational Verification of C Code with Refined Ownership Types"
// Main drawbacks:
// * Requires expert crafting rules
// * existentially quantified Coq variables (evars) for proofs must be carefully chosen
//   + finding existential variables is usually the hardest problem in automatized proves,
//     so it looks unfeasible to automatize for "non-experts"

int helper_seq_points(int *a);
int helper_seq_points(int *a) {
  *a = *a + 1;
  return *a;
}

void sequence_points_ub(void);
// SHENNANIGAN
void sequence_points_ub(void) {
  int a = 0;
  // a = a++ + b++; // Multiple unsequenced modifications to a
  // Same problem without warnings:
  a = helper_seq_points(&a) + helper_seq_points(&a);
}

void aliasing_loader_clobberd_by_store(int *a, int const *b);
// SHENNANIGAN
// Aliasing protection in C/C++ is based on type equivalence (in Rust not):
void aliasing_loader_clobberd_by_store(int *a, int const *b) {
  for (int i = 0; i < 10; i += 1) {
    a[i] += *b;
  }
}

void noaliasing(int *a, long const *b);
void noaliasing(int *a, long const *b) {
  for (int i = 0; i < 10; i += 1) {
    a[i] += *b;
  }
}
void noaliasing_with_restrict(int *__restrict__ a, int const *b);
void noaliasing_with_restrict(int *__restrict__ a, int const *b) {
  for (int i = 0; i < 10; i += 1) {
    a[i] += *b;
  }
}

void ptr_cmp(int *a, int const *b);
// SHENNANIGAN
// Additional pointer semantics created unnecessary UB, so one has to compare
// against 0 to be always compatible.
void ptr_cmp(int *a, int const *b) {
  if (a != 0 && b != 0) {
    *a = *a + *b;
  }
}
// Using this from C is UB:
//   extern C {
//     int* a = nullptr;
//   }
// or using this from C++ is UB:
//   int* a = void*;

void convert_string_to_int(char const *buff);
// SHENNANIGAN
// No readable, portable simple to use, handling all standard cases for ascii standard
// conversion routines for string to integer. <C++23> is worse without boost.
// This code is uselessly verbose (ignore non-portable printf qualifiers for now) taken from
// https://wiki.sei.cmu.edu/confluence/display/c/ERR34-C.+Detect+errors+when+converting+a+string+to+a+number
// Note, that errno can be set directly.
// #include <errno.h> #include <limits.h> #include <stdlib.h> #include <stdio.h>
void convert_string_to_int(char const *buff) {
  char *end;
  int si;
  errno = 0;
  long const sl = strtol(buff, &end, 10);
  if (end == buff) {
    (void)fprintf(stderr, "%s: not a decimal number\n", buff);
  } else if ('\0' != *end) {
    (void)fprintf(stderr, "%s: extra characters at end of input: %s\n", buff, end);
  } else if ((LONG_MIN == sl || LONG_MAX == sl) && ERANGE == errno) {
    (void)fprintf(stderr, "%s out of range of type long\n", buff);
  } else if (sl > INT_MAX) {
    (void)fprintf(stderr, "%ld greater than INT_MAX\n", sl);
  } else if (sl < INT_MIN) {
    (void)fprintf(stderr, "%ld less than INT_MIN\n", sl);
  } else {
    si = (int)sl;
    (void)si;
    // ..
  }
}

void convert_string_to_int_simple(char const *buff);
void convert_string_to_int_simple(char const *buff) {
  char *end;
  int si;
  errno = 0;
  long const sl = strtol(buff, &end, 10);
  if ((end != buff) && ('\0' == *end) && !((LONG_MIN == sl || LONG_MAX == sl) && ERANGE == errno) && (sl >= INT_MIN) &&
      (sl <= INT_MAX)) {
    si = (int)sl;
    (void)si;
    // ..
  }
}

// SHENNANIGAN
// create a list data structure implies 3 options:
// * Make it generic using preprocessor directives (boils down to reimplementing or using C11 or generators)
// * Make it generic using 'void *' instead of actual types
// * Not making generic and reimplement for each type.

// SHENNANIGAN
// `malloc(sizeof(MyType) * count)` breaks, if count is not given
// strongly typed C solution requires (C99 generators or C11 generics)
// C++ solution:
// template<typename T>
// __attribute__((malloc)) static inline T * allocate(size_t count) {
//     return reinterpret_cast<T*>(malloc(count * sizeof(T)));
// }

int no_reinterpret_cast(void);
// SHENNANIGAN reinterpret_cast does not exist making different pointer type access UB
// > Dereferencing a pointer that aliases an object that is not of a
// > compatible type or one of the other types allowed by
// > C 2011 6.5 paragraph 71 is undefined behavior.
// => The proper fix for access a pointer with increased alignment is to use a
// temporary with memcopy
int no_reinterpret_cast(void) {
  //impl_reinterpret_cast_usage
  // clang-format off
  char const some_vals[9] = {0, 1, 0, 0, 0, 0, 0, 0, 0};
  // clang-format on
  // WRONG: int64_t val = *((uint64_t*)&some_vals[1]);
  int64_t val;
  // more type safe than reinterpret_cast, because some_vals[1] is a type error
  memcpy(&val, &some_vals[1], 8);
  if (val != INT64_MIN)
    return 1;
  return 0;
}

int ptr_no_reinterpret_cast(void);
// SHENNANIGAN unclear risk from clang/gcc provenance related miscomplations
int ptr_no_reinterpret_cast(void) {
  char arr[4] = {0, 0, 0, 1};
  int32_t i32_arr = 0; // unnecessary variable hopefully elided
  memcpy(&i32_arr, &arr[0], 4);
  int32_t *i32_arr_ptr = &i32_arr;
  (void)i32_arr_ptr;
  // SHENNANIGAN dont return stack local variable here!
  return 0;
}

struct sStruct1 {
  uint8_t a1;
  uint8_t a2;
  char _pad1[30];
  uint32_t b1;
  uint32_t b2;
};

int32_t padding(void);
// Ensure correct storage and padding size for pointers via sizeof.
int32_t padding(void) {
  struct sStruct1 *str1 = malloc(sizeof(struct sStruct1));
  if (str1 == NULLPTR)
    return 1;
  str1->a1 = 5;
  free(str1);
  return 0;
}

void allowed_aliasing(uint16_t *bytes, int32_t len_bytes, uint16_t *lim);
void allowed_aliasing(uint16_t *bytes, int32_t len_bytes, uint16_t *lim) {
  for (int i = 0; i < len_bytes; i += 1) {
    if (bytes == lim)
      break;
    bytes[i] = 42;
  }
}
// void non_allowed_aliasing(uint16_t * bytes, int32_t len_bytes, uint8_t * lim) {
//   for(int i=0; i<len_bytes; i+=1) {
//     if (bytes == lim) break;
//     bytes[i] = 42;
//   }
// }

// typedef struct convention
typedef struct structname {
  int some_var;
} structname_s;

// SHENNANIGAN
// clang and gcc do not support relative paths for object file output

// MSVC SHENNANIGAN
// https://developercommunity.visualstudio.com/t/please-implement-integer-overflow-detection/409051
// Visual Studio 2022 version 17.7 has some non-optimal way of checking
// https://developercommunity.visualstudio.com/t/10326281
// Still much slower code due to missing intrinsics for overflow checks
// https://developercommunity.microsoft.com/t/Support-for-128-bit-integer-type/879048
// 128-bit types are neither supported
// https://stackoverflow.com/questions/69565333/are-there-overflow-check-math-functions-for-msvc
// Hope that undefined behavior from overflow does not break the code and use the intrinsics for reading output
// https://wiki.sei.cmu.edu/confluence/display/c/INT32-C.+Ensure+that+operations+on+signed+integers+do+not+result+in+overflow
// slow standard approaches, because microsoft neither supports inline assembly

int testEq(int a, int b);
int testEq(int a, int b) {
  if (a != b) {
    // Prefer __FILE_NAME__ to prevent absolute paths making builds non-reproducible
    fprintf(stderr, "%s:%d got '%d' expected '%d'\n", __FILE__, __LINE__, a, b);
    return 1;
  }
  return 0;
}

// Non-trivial C
// https://zackoverflow.dev/writing/how-to-actually-write-c
// https://zackoverflow.dev/writing/premature-abstraction

void printf_align(void);
void printf_align(void) {
  // pad the input right in a field 10 characters long
  printf("|%-10s|", "Hello");
}

// function pointer example from https://stackoverflow.com/questions/252748/how-can-i-use-an-array-of-function-pointers
int32_t sum(int32_t a, int32_t b);
int32_t sub(int32_t a, int32_t b);
int32_t mul(int32_t a, int32_t b);
int32_t div_noconflict(int32_t a, int32_t b);
int32_t sum(int32_t a, int32_t b) { return a + b; }
int32_t sub(int32_t a, int32_t b) { return a - b; }
int32_t mul(int32_t a, int32_t b) { return a * b; }
int32_t div_noconflict(int32_t a, int32_t b) { return (b != 0) ? a / b : 0; }

void use_callbacks(void);
void use_callbacks(void) {
  // Array of function pointers initialization
  int32_t (*callbacks[4])(int32_t, int32_t) = {sum, sub, mul, div_noconflict};

  // Using the function pointers
  int32_t result;
  int32_t i = 20, j = 5, op;

  for (op = 0; op < 4; op++) {
    result = callbacks[op](i, j);
    fprintf(stdout, "Result: %d\n", result);
  }
}

void fn_voidptr(void *raw_ptr, uint64_t len);
// SHENNANIGAN const char* to void* cast has unhelpful error messages
void fn_voidptr(void *raw_ptr, uint64_t len) { memset(raw_ptr, 0, len); }

void use_voidptr(void);
void use_voidptr(void) {
  char *sVars[] = {
      "MAIN.bIn_Overflow",
      "MAIN.bIn_Counter",
  };
  fn_voidptr((void *)sVars[0], strlen(sVars[0]));
}

// SHENNANIGAN standard flag for Windows
// WIN32_LEAN_AND_MEAN
// silently removes deprecated code

// standard approach
// #if defined(_WIN32)
// #define NOMINMAX
// #define WIN32_LEAN_AND_MEAN
// #include <windows.h>
// #else // !defined(_WIN32)
// #endif // defined(_WIN32)

// Very awful, if used within stdafx.h:
//   #pragma once
//   #include "targetver.h"
//   // Excludes rarely-used stuff from Windows headers
//   #define WIN32_LEAN_AND_MEAN
//   // Windows Header Files:
//   #include <windows.h>

#if defined(_WIN32)
void ape_win_incompat_fileprint(void);
// different semantics of "secure fns" and not portable
void ape_win_incompat_fileprint(void) {
  FILE *f1;
  char const *f1_name = "file1";
  char err_buf[100];
  errno_t err = fopen_s(&f1, f1_name, "a+");
  if (err != 0) {
    /* err = */ strerror_s(err_buf, 100, err);
    fprintf(stderr, "cannot open file '%s': %s\n", f1_name, err_buf);
  } else {
    fprintf(f1, "some_print_text\n");
    fclose(f1);
  }
}
#endif // defined(_WIN32)

// silence clangd warnings
#if !defined(_WIN32)
void ape_fileprint(void);
void ape_print(void);
void ape_fileprint(void) {
  char const *f1_name = "file1";
  FILE *f1 = fopen(f1_name, "a+");
  if (f1 == NULL) {
    fprintf(stderr, "cannot open file '%s': %s\n", f1_name, strerror(errno));
  } else {
    fprintf(f1, "some_print_text\n");
    fclose(f1);
  }
}
#endif // !defined(_WIN32)

#if defined(_WIN32)
#if defined(_MSC_VER)
// #define _CRT_SECURE_NO_WARNINGS
// #define _CRT_SECURE_NO_DEPRECATE
#endif // defined(_MSC_VER)
void ape_win_print(void);
void ape_win_print(void) {
  FILE *f1;
  fopen_s(&f1, "file1", "a+");
  fprintf(f1, "sometext\n");
  fclose(f1);
}
#endif // defined(_WIN32)

#if !defined(_WIN32)
void ape_print(void) {
  FILE *f1 = fopen("file1", "a+");
  if (f1 != NULLPTR) {
    fprintf(f1, "sometext\n");
    fclose(f1);
  }
}
#endif // !defined(_WIN32)

// Less known/arcane/cursed C based on https://jorenar.com/blog/less-known-c
// -Wvla-larger-than=0
// -Wvla
void array_pointers(void);
void array_pointers(void) {
  int arr[10];
  int *ap0 = arr;
  ap0[0] = 5;
  int (*ap1)[10] = &arr;
  (*ap1)[1] = 10;

  // multi-dimensional array on heap
  int (*ap3)[9000][9000] = malloc(sizeof(*ap3));
  if (ap3 != NULLPTR)
    free(ap3);

  // Variable Length Array (on stack)
  int (*ap4)[1000][1000] = malloc(sizeof(*ap4));
  if (ap4 != NULLPTR) {
    // (*arr)[i][j]
    free(ap4);
  }

  // alternative (worse to use): 1d array with offsets, piecewise allocation or big fixed array
  int *arr_1D = malloc(1000 * 1000 * (sizeof(*arr)));
  if (arr_1D != NULLPTR) {
    // arr_1D[1000*i + j] = 10;
    // ..
    free(arr_1D);
  }
}

// comma separator
// only rightmost expressions is considered
// b = (a=1, a+5);
// <=> a=1; b=1+5=6;

// digraphs, triggraphs, alternative tokens (ASCII)

struct Des1 {
  int x, y;
  char const *s1;
};

void designated_initializer(void);
// Designated initializer allow very ugly code, but also reasonable
// array initialization since C99
void designated_initializer(void) {
  int arr0[] = {1, 2, [10] = 8, [17] = 9};
  (void)arr0;
  struct Des1 d1 = {.y = 1, .s1 = "blubb", .x = -1};
  (void)d1;
  struct M1 {
    int x;
    int y;
    int z;
  };
  struct M1 arr1[] = {
      [0] = {0, 1, 9},
      [1] = {3, 4, 5},
      [2] = {6, 7, 8},
  };
  (void)arr1;
  struct {
    int sec, min, hour, day, mon, year;
  } dt1 = {.day = 1, 1, 2001, .sec = 1, 1, 1};
  (void)dt1;
}

// Compound literals looks like brace-enclosed initializer list
struct ComLit1 {
  int x, y;
};
void compound_literal(struct ComLit1 cl1);
void compound_literal_by_addr(struct ComLit1 *cl1);
void compound_literal_usage(void);

void compound_literal(struct ComLit1 cl1) { fprintf(stdout, "%d, %d\n", cl1.x, cl1.y); }
void compound_literal_by_addr(struct ComLit1 *cl1) { fprintf(stdout, "%d, %d\n", cl1->x, cl1->y); }
void compound_literal_usage(void) {
  // fun fact: red brackets by clangd show that this is cursed
  compound_literal((struct ComLit1){1, 2});
  compound_literal_by_addr(&(struct ComLit1){1, 2});
}

// SHENNANIGAN one can escape shadowing potentially resulting in weird errors
// int x_global_cursed = 13;
// void escaping_shadowing() {
//   int x = 1;
//   (void)x;
//   {
//     extern int x;
//     fprintf(stdout, "%d\n", x);
//   }
// }

// void multi_character_constants(void);
// SHENNANIGAN implementation dependent, so best to avoid them
// [-Wfour-char-constants] warning: multi-character character constant
// void multi_character_constants(void) {
//   enum State1 {
//     Wait = 'WAIT',
//     run = 'RUN!',
//     stop = 'STOP',
//   };
// }

void bitfields(void);
// SHENNANIGAN implementation defined behavior for nesting due to being underspecified
void bitfields(void) {
  struct Bitfield1 {
    unsigned int b0 : 3;
    unsigned int b1 : 4;
  };
}

void zero_bitfield(void);
// SHENNANIGAN 0 bit field
void zero_bitfield(void) {
  struct ZeroBitField1 {
    unsigned char x : 5;
    unsigned short : 0;
    unsigned char y : 7;
  };
  // in memory:
  // char pad          short  b►undary
  // v    v            v
  // xxxxx000 00000000 yyyyyyy0
  // zero-length field causes position to move to next short boundary
}

int32_t flexible_array_member(void);
// Introduced with C99, few usage example
int32_t flexible_array_member(void) {
  struct FlexibleArrayMember {
    uint32_t len; // at least one other data member
    char _pad1[28];
    double arr[]; // flexible array member must be last
    // potential padding
  };
  struct FlexibleArrayMember *flex_arr_mem = malloc(5 * sizeof(struct FlexibleArrayMember));
  if (flex_arr_mem == NULLPTR)
    return 1;
  flex_arr_mem->len = 5;
  for (uint32_t i = 0; i < flex_arr_mem->len; i += 1)
    flex_arr_mem->arr[i] = 20;

  free(flex_arr_mem);
  return 0;
}

void imaginary_cursor_position_in_printf(void);
void imaginary_cursor_position_in_printf(void) {
  int pos1, pos2;
  char const *str_unknown_len = "some_string_here";
  fprintf(stdout, "write %n(%s)%n here\n", &pos1, str_unknown_len, &pos2);
  fprintf(stdout, "%*s\\%*s/\n", pos1, " ", pos2 - pos1 - 2, " ");
  fprintf(stdout, "%*s", pos1 + 1, " ");
}

// idea finish up https://jorenar.com/blog/less-known-c

#if defined(_linux)
void safe_debugging_on_unix() {
  // To see prints, run strace
  write(-1, "writes to non-existing file descriptors are still visible in strace");
}
#endif // defined(_linux)

// based on https://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
// idea motivation
// Duffs device inspired (case statement is legal within a sub-block
// of its matching switch statement
// [missing_content]

// https://cdacamar.github.io/data%20structures/algorithms/benchmarking/text%20editors/c++/editor-data-structures/
// * gpa buffer
// * rope
// * piece table
// * piece tree
// Research data structure tradeoffs upfront
// Create debug utilities for data structures very early on
// Immutable RB deletion is hard
//
// https://bitbashing.io/gc-for-systems-programmers.html
// idea basic RCU implementation

// C99 and later, you can have a (one-dimensional) flexible array member (FAM)
// at the end of a structure which is a Variable Length Array.
// VLA rules for offsets and padding are complex and while size may be padded
// without any element, access or pointer past it are still be UB.
struct Pixel {
  uint8_t red;
  uint8_t green;
  uint8_t blue;
};

struct ImageSimple {
  int32_t width;
  int32_t height;
  struct Pixel *pixels_simple;
};
extern struct ImageSimple s_image_simple;
// static struct ImageSimple s_image_simple;
// templates\common.c:904:27: warning: unused variable 's_image_simple' [-Wunused-variable]
//   904 | static struct ImageSimple s_image_simple;
//       |                           ^~~~~~~~~~~~~~
struct ImageSimple s_image_simple;

struct ImageVLA {
  int32_t width;
  int32_t height;
  struct Pixel pixels_vla[];
};
extern struct ImageVLA ImageVLA;
struct ImageVLA ImageVLA;
// C11 alignas for correct storage alignment
// align cast does not exist in contrast to C++ and scope-based
// type aliasing prevention does neither exist
// C11 alignas(struct foo)
// see also
// * __attribute__((aligned(128)))
// * _Alignas(128)

// Corresponding zig code:
// const Pixel = externs struct {
//     red: u8,
//     green: u8,
//     blue: u8,
// };
// pub ImageVLA = extern struct {
//   width: i32,
//   height: i32,
//   pixles_vla: [*]Pixel,
// };
// if using [255]u8 to cast into ImageVLA, use
// ptr with alignment 1: *align(1) Pixel

// https://stackoverflow.com/questions/6924195/get-dll-path-at-runtime
// EXTERN_C IMAGE_DOS_HEADER __ImageBase;
// TCHAR   DllPath[MAX_PATH] = {0};
// GetModuleFileName((HINSTANCE)&__ImageBase, DllPath, _countof(DllPath));

// SHENNANIGAN windows
// docs on job objects are very bad on runtime behavior
// TerminateJobObject does not terminate until some IO completion function is
// executed, which apparently executed pending job object tasks via callback.

// SHENNANIGAN windows
// related complex reliable waiting for process tree completion on windows
// I/O completion port and to listen for notifications JOB_OBJECT_MSG_ACTIVE_PROCESS_ZERO
// but:
//   Note that, except for limits set with the
//   JobObjectNotificationLimitInformation information class, messages are
//   intended only as notifications and their delivery to the completion port is
//   not guaranteed. The failure of a message to arrive at the completion port
//   does not necessarily mean that the event did not occur.
// * use GetQueuedCompletionStatus with upper time limit in a loop for "expected time behavior"
// * on "unpexpected time behavior/too much resource usage occurs" etc, use TerminateJobObject with another call to WaitForObject, WaitForObjectEx / the multiple object pendant or the GetQueuedCompletionStatus one to ensure pending job object tasks are executed
// * untested, but strong suggestion: make sure to wait/get status for at least all direct ancestors of your process so that all the dependency tasks are executed
// * untested, but unsure: make a test for other pending job object tasks and check that the job object tasks can be executed (nothing blocking it)
// * to be extra sure that nothing got lost in the meantime, use afterwards QueryInformationJobObject JOBOBJECT_BASIC_ACCOUNTING_INFORMATION and the field ActiveProcesses in a loop.
// link https://github.com/matu3ba/sandboxamples/blob/cd3998945a6e286c6ddc367d75fe8d5b50ca717a/test/win/main_job_api.zig
// https://superuser.com/questions/136272/how-can-i-kill-an-unkillable-process/295990#295990
// * see also "unkillable processes", where it depends how/when the kernel frees up resources for the process to be terminated.
// * one possible workaround is to kill the parent process and wait for it to wait for APC events,
//   but Kernel events might not be APC based and memory not be freed in that case

// Use realtime thread with minimal time period to execute, but keep 1 thread at a time, even if taking longer
// st = timeSetEvent(1, 0, &fnPtr, reinterpret_cast<DWORD_PTR>(this), TIME_PERIODIC | TIME_KILL_SYNCHRONOUS);

int FG_Init(char *errmsg_ptr, int *errmsg_len);
// SHENNANIGAN snprintf standard specification has ambiguous phrasing on 0 sentinel
// In practice implementations unconditionally add 0 sentinel.
//   if (*errmsg_len > 0) errmsg_ptr[*errmsg_len - 1] = 0x0;
int FG_Init(char *errmsg_ptr, int *errmsg_len) {
  char const *msg = "balbla";

  // int st = snprintf(errmsg_ptr, *errmsg_len, "%s", msg);
  //     'unsigned long long' [-Wsign-conversion]
  // 966 |   int st = snprintf(errmsg_ptr, *errmsg_len, "%s", msg);
  //     |            ~~~~~~~~             ^~~~~~~~~~~
  int st = snprintf(errmsg_ptr, (size_t)*errmsg_len, "%s", msg);
  if (st > 0)
    return 0;
  return 1;
}

//
//https://blog.quarkslab.com/unaligned-accesses-in-cc-what-why-and-solutions-to-do-it-properly.html
//#include <inttypes.h>
// static inline void * please_align(void * ptr){
//     char * res __attribute__((aligned(128))) ;
//     res = (char *)ptr + (128 - (uintptr_t) ptr) % 128;
//     return res ;
// }
// https://stackoverflow.com/questions/3839922/aligned-malloc-in-gcc
// _mm_alloc, _mm_free

//====signaling_win
// 3 signal types:
// * APC like IO completion ports which are just things to communicate
// see also my stackoverflow post
// * SEH exceptions first handled by debugger, then VEH exceptions, then SEH exceptions, then frame handler
// * async things which should be only SIGINT and exececuted by passing another thread
// https://www.osronline.com/article.cfm%5earticle=469.htm

// 1. Are signals executed sequentially or can other threads execute the handler
// in parallel?
// * Nothing in SEI guide on blocking signals or how they work
//   https://wiki.sei.cmu.edu/confluence/display/c/SIG01-C.+Understand+implementation-specific+details+regarding+signal+handler+persistence.
// * Kernel calls things, threads execute signal handlers individually by what
//   is registered in Kernel, code and debugger etc
// * unclear if multiple threads calling AddVectoredExceptionHandler and
//   RemoveVectoredExceptionHandler would be racy, so probably yes
// 2. Is there a method to prevent default handler being setup on second signal?
// * blocking signals not possible, only not handling SIGINT
// 3. What happens with pending signals? Are signals stacked or do we have a bitmask?
// * queued signals like SIGINT or APC (completion IO) are executed on after another
// * SEH signals are not
// * unclear what happens if multiple signals from different threads arrive
//   or if they can race against another for execution within SEH handlers
//   invoked by each thread
//
// AddVectoredExceptionHandler catches crash handlers (SEH):
// SIGSEGV, SIGABRT, SIGFPE, SIGILL, SIGTERM
// Async signals are forwarded to thread to be handled (eventually):
// SIGINT
// and completion IO signals are executed on callback once we wait for completion,
// the dependency chain is satisfied and nothing is blocking completion with signals
// only being forwarded/executed on again waiting for completion (via callback).
// Typical example are job objects.
// https://news.ycombinator.com/item?id=17770704
// https://stackoverflow.com/questions/26676826/how-do-i-install-a-signal-handler-for-an-access-violation-error-on-windows-in-c
// https://learn.microsoft.com/en-us/windows/win32/debug/structured-exception-handling
// https://stackoverflow.com/questions/28544768/vectored-exception-handling-process-wide

#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
void deinitTimer(void);
void resetOutputs(void);
LONG __stdcall Exception_Reset(struct _EXCEPTION_POINTERS *ExceptionInfo);
void veh_example(void);

void deinitTimer(void) {}
void resetOutputs(void) {}

// SHENNANIGAN windows
// no guide how to minimize headers to optimize compilation time
// only including below things fails in clangd with "No Target Architecture"
// #include <windef.h>
// #include <winnt.h>
LONG __stdcall Exception_Reset(struct _EXCEPTION_POINTERS *ExceptionInfo) {
  (void)ExceptionInfo;
  // 1. stop realtime thread via synchronously via timeKillEvent option TIME_KILL_SYNCHRONOUS
  deinitTimer();
  // 2. write outputs, which is safe due to realtime thread being stopped
  resetOutputs();
  return EXCEPTION_EXECUTE_HANDLER;

  // https://learn.microsoft.com/en-us/cpp/cpp/try-except-statement?view=msvc-170
  // EXCEPTION_CONTINUE_EXECUTION -1
  //   Exception is dismissed. Continue execution at the point where the exception occurred.
  // EXCEPTION_CONTINUE_SEARCH 0
  //   Exception isn't recognized. Continue to search up the stack for a handler, first for containing try-except statements, then for handlers with the next highest precedence.
  // EXCEPTION_EXECUTE_HANDLER 1
  //   Exception is recognized. Transfer control to the exception handler by executing the __except compound statement, then continue execution after the __except block.

  // overview of VEH: https://dimitrifourny.github.io/2020/06/11/dumping-veh-win10.html
  // https://dimitrifourny.github.io/2020/06/11/dumping-veh-win10.html
  // https://doar-e.github.io/blog/2013/10/12/having-a-look-at-the-windows-userkernel-exceptions-dispatcher/
  // Windows exceptions bubbled up per thread, so each thread can handle it individually
}

void veh_example(void) {
  const ULONG prepend = 1;
  // global exception handler executed per thread
  PVOID exception_h = AddVectoredExceptionHandler(prepend, Exception_Reset);
  (void)exception_h;
  // local exception handler executed per thread
}
#endif // defined(_WIN32)

//====printf_formatter
// * use clangd for quick non-portable advice
// * %[parameter][flags][width][.precision][length]type
// * printf("%" PRI(d|i)BITWIDTH, var); // signed integers
// * printf("%" PRI(u)BITWIDTH, var); // unsigned integers
// * printf("%" PRI(x|X)BITWIDTH, var); // hex values (lower|upper) case
// * float double upcasted to double before being printed
//   with specifiers (%a, %e, %f, %g) HEXa, exponent, float, g-special values
// * printf("%z(u|i|d|x)\n", sizeof(int64_t));
// * printf("%+" PRId64 "\n", INT64_MIN);
// * printf("%+" PRIi64 "\n", INT64_MIN);
// * printf("%+" PRIu64 "\n", UINT64_MAX);

// based on https://www.codeproject.com/articles/207464/exception-handling-in-visual-cplusplus
// without the wrong information:
// * VEHs are process global installed, but thread local executed
// AddVectoredExceptionHandler
// TODO FIXME set exception to reset peripherals
// Q: What happens, if for example realtime thread timeSetEvent gets timeKillEvent passed via exception from
// AddVectoredExceptionHandler ?
//https://stackoverflow.com/questions/28544768/vectored-exception-handling-process-wide
//https://www.codeproject.com/articles/207464/exception-handling-in-visual-cplusplus
//https://wiki.sei.cmu.edu/confluence/display/c/SIG01-C.+Understand+implementation-specific+details+regarding+signal+handler+persistence

#if defined(_WIN32)
BOOL WINAPI ConsoleHandler(DWORD);
int setup_SIGINT_handler(void);
void getFullPathNameUsage(void);

// On Windows, Ctrl-C/SIGINT is called from newly spawned thread
// and handled in ConsoleCtrlHandler.
// https://stackoverflow.com/questions/16826097/equivalent-to-sigint-posix-signal-for-catching-ctrlc-under-windows-mingw
BOOL WINAPI ConsoleHandler(DWORD dwType) {
  switch (dwType) {
    case CTRL_C_EVENT:
      printf("ctrl-c\n");
      break;
    case CTRL_BREAK_EVENT:
      printf("break\n");
      break;
    default:
      printf("Some other event\n");
  }
  return TRUE;
}

int setup_SIGINT_handler(void) {
  if (!SetConsoleCtrlHandler((PHANDLER_ROUTINE)ConsoleHandler, TRUE)) {
    fprintf(stderr, "Unable to install handler!\n");
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}

void getFullPathNameUsage(void) {
  char const *argv = "test123";
  char *fileExt;
  char szDir[256]; //dummy buffer
  GetFullPathName(&argv[0], 256, szDir, &fileExt);
  printf("Full path: %s\nFilename: %s", szDir, fileExt);
}

#endif // defined(_WIN32)

//====encoding
// general solution https://github.com/Davipb/utf8-utf16-converter
// no good portable solution taking minimal space https://thephd.dev/cuneicode-and-the-future-of-text-in-c
// prefer fwrite over fprintf to prevent locale effects
// formatters without local effects are yet unsolved in C, C++ has std::fmt for this
// use a modern language or set locale/codepage, context https://github.com/mpv-player/mpv/commit/1e70e82baa91

size_t utf8_to_utf16_buflen(uint8_t const *input, size_t input_len);
size_t utf8_to_utf16_buflen(uint8_t const *input, size_t input_len) {
  (void)input;
  (void)input_len;
  // TODO port the zig code
  return 0;
}
size_t utf8_to_utf16(uint8_t const *input, size_t input_len, uint16_t *output, size_t output_len);
size_t utf8_to_utf16(uint8_t const *input, size_t input_len, uint16_t *output, size_t output_len) {
  // TODO port the zig code
  (void)input;
  (void)input_len;
  (void)output;
  (void)output_len;
  return 0;
}

void use_utf8_to_utf16_static(void);
void use_utf8_to_utf16_static(void) {
  utf8_to_utf16_buflen(NULLPTR, 0);
  utf8_to_utf16(NULLPTR, 0, NULLPTR, 0);
  // TODO
}
void use_utf8_to_utf16_dynamic(void);
void use_utf8_to_utf16_dynamic(void) {
  // TODO
}

#if defined(_WIN32)
// TODO FIXUP of content into something usable uint8_t, uint16_t instead of char/WCHAR
// ideally usable with size_t but Windows appears to have nothing for this

#if !defined(WIN32_LEAN_AND_MEAN)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif // !defined(WIN32_LEAN_AND_MEAN)

// returns on success res >= 0
// * needed utf16 buffer len for utf8 to utf16 encoding
//         on failure res < 0
// * invalid unicode found in string
int win_utf8_to_utf16_buflen(char const *input, size_t input_len);
int win_utf8_to_utf16_buflen(char const *input, size_t input_len) {
  int needed_len = MultiByteToWideChar(CP_UTF8, 0, input, (int)input_len, NULL, 0);
  if (input_len == 0) {
    assert(needed_len == 0);
    return 0;
  }
  if (needed_len == 0)
    return -1; // ERROR_NO_UNICODE_TRANSLATION
  return needed_len;
}

// returns res < 0, iff error occured during conversion
//         res >=0, iff no error occured as number of bytes written including sentinel
//         * res == 0 implies that neither a sentinel was written
int win_utf8_to_utf16(char const *input, size_t input_len, WCHAR *output, size_t output_len);
int win_utf8_to_utf16(char const *input, size_t input_len, WCHAR *output, size_t output_len) {
  // idea: write yourself or use https://github.com/Davipb/utf8-utf16-converter
  int needed_len = win_utf8_to_utf16_buflen(&input[0], input_len);
  if (input_len == 0 && needed_len == 0)
    return 0;
  if (needed_len < 0)
    return -1; // utf8 or utf16 encoding issue
  if (output_len < (size_t)needed_len)
    return -2; // insufficient buffer size

  int bytes_written = MultiByteToWideChar(CP_UTF8, 0, input, -1, output, needed_len);
  if (bytes_written == 0) {
    // ERROR_INSUFFICIENT_BUFFER: supplied buffer size not large enough or incorrectly NULL.
    // ERROR_INVALID_FLAGS: values supplied for flags not valid.
    // ERROR_INVALID_PARAMETER: Any of param values was invalid.
    // ERROR_NO_UNICODE_TRANSLATION: Invalid Unicode found in a string.
    return -3; // should be unreachable but keep it for diagnostic
  }
  return bytes_written;
}

void use_win_utf8_to_utf16(void);
void use_win_utf8_to_utf16(void) {
  // setlocale(LC_ALL,"");
  char in[256] = "x0123456789ABCDEF";
  WCHAR out[256] = L"";

  // FILE* file = fopen("data.txt", "r");
  // fgets(in, 255, file);
  // fclose(file);

  int bytes_or_err = win_utf8_to_utf16(&in[0], strlen(in), &out[0], sizeof(out));
  if (bytes_or_err < 0) {
    (void)fprintf(stderr, "error utf8 to utf16 conversion: %s\n", &in[0]);
    return;
  }
  (void)fprintf(stdout, "written bytes into utf16 buf: %d\n", bytes_or_err);
}

#endif // defined(_WIN32)

//====signaling_unix
// signal deprecated/undefined, because they have sigprocmask and signal is implementation defined by C standard

// https://maskray.me/blog/2024-05-12-exploring-gnu-extensions-in-linux-kernel
// funny kernel macros and flags to workaround standard issues due to type based aliasing analysis

// delayed loaded via explicit calls to LoadLibrary and GetProcAddress

// #include<windows.h>
// #include<unistd.h>
// Sleep/sleep

// https://gustedt.wordpress.com/2021/10/18/type-safe-parametric-polymorphism/
// C23 attributes
// idea Agni? started this with type-safe printing via C23 generic selection
// could use something similar

// NOLINTBEGIN(clang-diagnostic-padded)
struct TaggedUnion {
  union TheUnion {
    uint64_t const *u64ptr;
    uint8_t const *u8ptr;
  } m_TheUnion;
  enum TheTag {
    u64ptr,
    u8ptr,
  } m_TheTag;
  char _pad[4]; // padding
};
// NOLINTEND(clang-diagnostic-padded)
// struct TaggedUnion initTaggedUnion(union TheUnion, enum TheTag){}

void tagged_union(void);
void tagged_union(void) {

  // idea std::variant equivalent
  // idea enum class equivalent
  // idea could abuse macros to namespace a struct integer and make
  // associated integers
}

void enum_class(void);
void enum_class(void) {
  // idea enum class equivalent
}

void C99use_double_min(void);
void C99use_double_min(void) {
  // ANSI C: ANSIC_double_min = -FLT_MAX;
  // ANSI C: ANSIC_double_min = -DBL_MAX;
  float float_min = -INFINITY;
  (void)float_min;
  float float_min_alt = -HUGE_VALF;
  (void)float_min_alt;
  double double_min = -HUGE_VAL;
  (void)double_min;
  long double long_double_min = -HUGE_VALL;
  (void)long_double_min;
}

static int C99cmp_int(void const *a, void const *b) {
  int arg1 = *(int const *)a;
  int arg2 = *(int const *)b;

  // required to use -1,0,1 or wrong result is returned
  if (arg1 < arg2)
    return -1;
  if (arg1 > arg2)
    return 1;
  return 0;
}
void C99use_qsort(void);
void C99use_qsort(void) {
  int ints[] = {-2, 99, 0, -743, 2, INT_MIN, 4};
  size_t size = sizeof ints / sizeof ints[0];
  qsort(ints, size, sizeof(int), C99cmp_int);
}

// sorting without C11
// roll your own sortin algos

// https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2809r3.html
// Forward progress guarantees
// An iteration statement may be assumed by the implementation to terminate if
// its controlling expression is not a constant expression, and none of the
// following operations are performed in its body, controlling expression or (in
// the case of a for statement) its expression:
// * input/output operations
// * accessing a volatile object
// * synchronization or atomic operations.
// Applicative to
// while ( expression ) statement
// do statement while ( expression ) ;
// for ( expressionopt ; expressionopt ; expressionopt ) statement
// for ( declaration expressionopt ; expressionopt ) statement

// https://github.com/gritzko/librdx/blob/master/ABC.md
// scalable high perf code requirements
// idea look into this for parallel programming

// GENERAL

// based on https://en.cppreference.com/w/c/language/operator_precedence
//Prec|  Op          | Description                              | Associativity(what comes first)
// 1  | ++ --        | Suffix/postfix increment and decrement   | Left-to-right
//    | ()           | Function call                            |
//    | []           | Array subscripting                       |
//    | .            | Structure and union member access        |
//    | ->           | Struct and union member access via ptr   |
//    | (type){list} | Compound literal(C99)                    |
// 2  | ++ --        | Prefix increment and decrement[note 1]   | Right-to-left
//    | + -          | Unary plus and minus                     |
//    | ! ~          | Logical NOT and bitwise NOT              |
//    | (type)       | Cast                                     |
//    | *            | Indirection (dereference)                |
//    | &            | Address-of                               |
//    | sizeof       | Size-of[note 2]                          |
//    |_Alignof      |                                          | Alignment requirement(C11)               |
// 3  | * / %        | Multiplication, division, and remainder  | Left-to-right
// 4  | + -          | Addition and subtraction                 |
// 5  | << >>        | Bitwise left shift and right shift       |
// 6  | < <=         | For rel. op < and ≤                      |
//    | > >=         | For rel. op > and ≥                      |
// 7  | == !=        | For rel. = and ≠                         |
// 8  | &            | Bitwise AND                              |
// 9  | ^            | Bitwise XOR (exclusive or)               |
// 10 | |            | Bitwise OR (inclusive or)                |
// 11 | &&           | Logical AND                              |
// 12 | ||           | Logical OR                               |
// 13 | ?:           | Ternary conditional                      | Right-to-left
// 14 | =            | Simple asgn                              |
//    | += -=        | Asgn by sum and difference               |
//    | *= /= %=     | Asgn by product, quotient, and remainder |
//    | <<= >>=      | Asgn by bitwise left + right shift       |
//    | &= ^= |=     | Asgn by bitwise AND, XOR, and OR         |
// 15 |  ,           | Comma                                    | Left-to-right

// SHENNANIGAN Evaluation order of operators is undefined, the operator
// precedence only describes the type of the result, not how it is evaluated.
// Prefer to use new statements, if possible to remove evaluation order ambiguity.
// See also ./example/operator_precedence.c

#if defined(HAS_C11)
static _Thread_local uint32_t threadloc_var = 0;
struct C11_alignment_struct {
  uint8_t first;
  char _pad1[3];
  uint32_t second;
  uint64_t third;
};
// #include <stdalign.h> empty for msvc libc
void C11_alignment_control(void);
void C11_alignment_control(void) {
  static_assert(_Alignof(char) == 1, "char has no alignment of 1");
  fprintf(stdout, "%zu\n", _Alignof(struct C11_alignment_struct));
  _Alignas(128) _Atomic uint32_t mutex;
  (void)mutex;
  (void)threadloc_var;
  // SHENNANIGAN allocation fns
#if defined(_WIN32)
  uint8_t *ptr_aligned_mem = _aligned_malloc(1024, 1024);
  _aligned_free(ptr_aligned_mem);
#else  // !defined(_WIN32)
  uint8_t *ptr_aligned_mem = aligned_alloc(1024, 1024);
  free(ptr_aligned_mem);
#endif // defined(_WIN32)
}

// #include <stdnoreturn.h> void C11_noreturn() {} deprecated

// Dont use <threads.h> with C11 threads, not implemented on Windows and Apple
// Defacto deprecated, better use pthread or platform primitives
// #include <threads.h>

#include <stdatomic.h>
struct No_Immutable_in_C_i64 {
  _Atomic int64_t *p1;
  _Atomic int64_t cnt;
};
int32_t immut_set(struct No_Immutable_in_C_i64 *obj, int64_t val);
int32_t immut_get(struct No_Immutable_in_C_i64 *obj, int64_t *val);

// C provides no nice way to get generics (besides C11 non C++ usable generic
// selection), so (usually) it makes no sense to have a method 'update' being
// usable as callback with additional type and runtime safety checks.
// Typical C++ concepts based heavily on operators, constructors and inlined
// templates with non-atomic operations are not automatically applicable.
// Upside: Performance explicit, Downside: more verbose to write get/set
// methods, no good way to use struct generically by filling fn ptr/callback for
// additional method 'update'.
// Omit shared_ptr methods here for brevity.
int32_t immut_set(struct No_Immutable_in_C_i64 *obj, int64_t val) {
  if (obj != NULL) {
    atomic_store(obj->p1, val);
    return 0;
  }
  return 1;
}
int32_t immut_get(struct No_Immutable_in_C_i64 *obj, int64_t *val) {
  if (obj != NULL) {
    *val = atomic_load(obj->p1);
    return 0;
  }
  return 1;
}

// sorting with context
// static_assert(__STDC_WANT_LIB_EXT1__);
// int C11cmp_int_s(const void* a, const void* b, void* context) {
//     int arg1 = *(const int*)a;
//     int arg2 = *(const int*)b;
//     // context
//
//     if (arg1 < arg2) return -1;
//     if (arg1 > arg2) return 1;
//     return 0;
// }
// void C11use_qsort_s(void) {
//     int ints[] = {-2, 99, 0, -743, 2, INT_MIN, 4};
//     int size = sizeof ints / sizeof *ints;
//     qsort(ints, size, sizeof(int), C11cmp_int_s);
// }
#endif // defined(HAS_C11)

#if defined(HAS_C17)
// only fixed defects
// supports realloc with size = 0
#endif // defined(HAS_C17)

#if defined(HAS_C23)
// breaking changes
// * _Thread_local -> thread_local
#if __has_include(<stdckdint.h>)
#include <stdckdint.h>
#endif
[[deprecated]] // warning on usage and clangd shows strikedthrough text
void C23_deprecated();
void C23_deprecated() {}
[[nodiscard]] // warning on usage of discarded code
int C23_discard(int x);
int C23_discard(int x) { return x + 1; }
// SHENNANIGAN C23 has no macros to test target for branch-free wraparound or
// saturation arithmetic (+|,|*)
// SHENNANIGAN C23 has no saturation arithmetic
void C23_wraparound_operations();
void C23_wraparound_operations() {
  uint64_t a = UINT64_MAX;
  uint64_t b = UINT64_MAX;
  uint64_t res_mul;
  if (ckd_mul(&res_mul, a, b)) {
    fprintf(stdout, "non-zero return: overflow");
  } else {
    fprintf(stdout, "no overflow");
  }
}
// SHENNANIGAN C23 constexpr primarily to avoid VLAs
// without constexpr fns
void C23_constexpr();
void C23_constexpr() {
  constexpr float fvar = 23.0f;
  constexpr int32_t ivar = 1;
  constexpr char svar[] = "some_text";
  fprintf(stdout, "%f%d%s\n", (double)fvar, ivar, svar);
}
void C23_typecoercion();
void C23_typecoercion() {
  // turn clang-format off, because it breaks 1'000'000
  // clang-format off
  auto x = 0b1111;         // new binary integer constants
  typeof(x) y = 1'000'000; // new separators
  printf("%d\n", x);       // prints 15
  printf("%d\n", y);       // prints 1000000
  // clang-format on
}
void C23_constexpr_to_prevent_VLA();
void C23_constexpr_to_prevent_VLA() {
  constexpr int32_t N = 10;
  static_assert(N == 10);
  bool a[N]; // array of N booleans instead of VLA
  for (int i = 0; i < N; ++i) {
    a[i] = true;
  }
  fprintf(stdout, "%d\n", a[0]);
}
// bool became a keyword since C17?
// SHENNANIGAN char8_t was added instead of defaulting strings to UTF-8
// [[noreturn]] instead of annotation

enum efields : uint16_t { // best practice to specify len of enum
  efields_x
};
int32_t C23_simple_generic_selection_on_enum();
int32_t C23_simple_generic_selection_on_enum() { return _Generic(efields_x, uint16_t: 0, default: 1); }
enum values : uint64_t {
  values_a = 0,             // int
  values_b = 1,             // int
  values_c = 3,             // int
  values_d = 0x1000,        // int
  values_f = 0xFFFFF,       // int
  values_g,                 // implicit +1, on 16-bit platform upgrades type of constant
  values_e = values_g + 24, // current type of g - long or long long to do math and set value to e
  values_i = ULLONG_MAX     // unsigned long or unsigned long long
};
int32_t C23_complex_generic_selection_on_enum();
int32_t C23_complex_generic_selection_on_enum() {
  // when enum is complete, it can select any type that it wants, so long as its
  // big enough to represent the type
  return _Generic(values_a, unsigned long: 1, unsigned long long: 0, default: 3);
}

#if __has_include(<stdbit.h>)
#include <stdbit.h>
void C23_stdbit();
void C23_stdbit() {
  if (__STDC_ENDIAN_NATIVE__ == __STDC_ENDIAN_LITTLE__) {
    assert(__STDC_ENDIAN_NATIVE__ == __STDC_ENDIAN_LITTLE__);
  } else {
    assert(__STDC_ENDIAN_NATIVE__ == __STDC_ENDIAN_BIG__);
  }
  //  stdc_popcount
  //  stdc_bit_width
  //  stdc_leading_zeroes/stdc_leading_ones/stdc_trailing_zeros/stdc_trailing_ones
  //  stdc_first_leading_zero/stdc_first_leading_one/stdc_first_trailing_zero/stdc_first_trailing_one
  //  stdc_has_single_bit
  //  stdc_bit_width
  //  stdc_bit_ceil
  //  stdc_bit_floor
}
#endif

// not working in clang 19.1.2 using Windows libc
// void C23_memset_explicit();
// void C23_memset_explicit() {
//   char mem1[100];
//   memset_explicit(&mem1[0], 0, sizeof(mem1));
// }

// -Wnullability-completeness
// -Wnullability-extension

// not quite sure why
// #if defined(__clang__)
// // custom optional and non-standard attributes
// #pragma clang diagnostic push
// #pragma clang diagnostic ignored "-Wnullability-extension"
// void Str_Copy_NonNull(char const *_Nonnull str, int32_t strlen, char *_Nonnull str2);
// /// assume: continuous data pointed by input str terminated with 0x00
// /// assume: str2 has sufficient backed memory size
// /// copy strlen chars from str to str2
// void Str_Copy_NonNull(char const *_Nonnull str, int32_t strlen, char *_Nonnull str2) {
//   for (int i = 0; i < strlen; i += 1)
//     str2[i] = str[i];
// }
// #pragma clang diagnostic pop
// #endif // defined(__clang__)

// memset_explicit

//====keywords as of C23
// alignas alignof auto bool break
// case char const constexpr continue
// default do double else enum
// extern false float for goto
// if inline int long nullptr
// register restrict return short signed
// sizeof static static_assert struct switch
// thread_local true typedef typeof typeof_unqual
// union unsigned void volatile while
// _Atomic _BitInt _Complex _Decimal32 _Decimal64
// _Decimal128, _Generic _Imaginary
// * macro keywords
// if elif else endif ifdef (better: #if defined(..))
// ifndef (better: #if !defined(..)) elif defined(elifndef define undef)
// include embed line error warning
// pragma defined __has_include __has_embed __has_c_attribute
// * tokens outside of preprocessor
// _Pragma
// * extensions conditionally supported
// asm fortran
// => 53 + 20 + 3 = 76
//====builtins
// compiler specific and not guaranteed to be stable across versions
#endif // defined(HAS_C23)

// 1. flag -msse2
//#if defined(__SSE2__)
//  #include <emmintrin.h>
//#else // !defined(__SSE2__)
//  #error SSE2 not supported.
//#endif // defined(__SSE2__)
// 2. flag -mavx
//#if defined(__AVX__)
//  #include <immintrin.h>
//#else // !defined(__AVX__)
//  #error AVX not supported.
//#endif // defined(__AVX__)
// 3. flag -fopenmp-simd
// Intel-portable SIMD via #include <immintrin.h>
// Windows SIMD via #include <intrin.h>
// BEST: use another language offering portable SIMD via LLVM or own impl

// idea: do some simd https://blog.mattstuchlik.com/2024/07/21/fastest-memory-read.html

int32_t main(void) { return 0; }
