#include <assert.h>
#include <stdint.h> // uint32_t, uint8_t
#include <stdlib.h> // exit
#include <stdio.h>  // fprintf
#include <errno.h>  // errno
#include <limits.h> // limit
#include <string.h> // memcpy
#include <inttypes.h> // PRIXPTR and other portable printf formatter

//====tooling
//====version
//====lto
//====pointers
//====signaling on Posix
//====signaling on Windows

//====tooling
// cerberus
// clang-tidy
// cppcheck
// frama-c
// DWARF and ELF verified spec impl + model usable as test oracle https://github.com/rems-project/linksem
// TODO more checks
// psyche-e incomplete file completer and compiler https://github.com/ltcmelo/psychec http://cuda.dcc.ufmg.br/psyche-c/

//====version
// setting iso version:
// clang4  -std=c89
// clang4  -std=c99
// clang4  -std=c11
// clang6  -std=c17
// clang18 -std=c23

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

// https://github.com/Hirrolot/metalang99, datatype99, interface99
// https://github.com/Gankra/abi-cafe

// https://ahgamut.github.io/2022/10/23/debugging-c-with-cosmo/
// Debugging with cosmopolitcan libc

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

// Exceptions:
// - posix extension/Windows: casting pointers to functions (and back) also use for dynamic linking etc
// - clang and gcc have -fno-strict-aliasing, msvc and tcc do disable type-based aliasing analysis based optimizations
// - no switch to disable provenance-based alias analysis in compilers (clang, gcc, msvc, tcc)
// - Usage of restrict can be en/disabled in all compilers via #pragma optimize("", on/off).
//   It can also be disabled in all compilers via #define restrict, using an according optimization level (typical -O1)
//   or via separating header and implementation and disabling link time optimziations.

static void memset_16aligned(void * ptr, char byte, size_t size_bytes, uint16_t alignment) {
    assert((size_bytes & (alignment-1)) == 0); // Size aligned
    assert(((uintptr_t)ptr & (alignment-1)) == 0); // Pointer aligned
    memset(ptr, byte, size_bytes);
}
// 1. Careful with segmented address spaces: lookup uintptr_t semantics
// 2. Careful with long standing existing optimization compiler bugs pointer to
// integer and back optimizations in for example clang and gcc
// 3. Careful with LTO potentially creating problem 2. (clang -flto -funified-lto -fuse-ld=lld ptrtoint_inttoptr.c)
// 4. Consider C11 aligned_alloc or posix_memalign
void ptrtointtoptr() {
  const uint16_t alignment = 16;
  const uint16_t align_min_1 = alignment - 1;
  void * mem = malloc(1024+align_min_1);
  // C89: void *ptr = (void *)(((INT_WITH_PTR_SIZE)mem+align_min_1) & ~(INT_WITH_PTR_SIZE)align_min_1);
  // ie void *ptr = (void *)(((uint64_t)mem+align_min_1) & ~(uint64_t)align_min_1);
  // offset ptr to next alignment byte boundary
  void * ptr = (void *)(((uintptr_t)mem+align_min_1) & ~(uintptr_t)align_min_1);
  printf("0x%08" PRIXPTR ", 0x%08" PRIXPTR "\n", (uintptr_t)mem, (uintptr_t)ptr);
  memset_16aligned(ptr, 0, 1024, alignment);
  free(mem);
}

// macro NULL = 0 or mingw null

void assert_with_text() {
  assert((1 == 1) && "sometext");
}

void standard_namespacing() {
  // Standard enum, struct etc
  struct Namespace1 {
    // unscoped enum place fields into outest file scope
    enum Mode {
      Undefined,
      Mode1,
      Mode2,
    } eMode;
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

  switch (sNamespace1.eMode) {
  case Undefined:
      break;
  case Mode1:
      break;
  case Mode2:
      break;
  default:
    break;
  }
}

void c_enum_in_struct_weirdness() {
  const uint32_t device_type = 1;
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

void cpp_namespaces_enums_in_structs(int32_t device_type) {
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
  // c compiler: Use of undeclared identifier 'BeckhoffDeviceType'
  // cpp compiler: works fine and might be needed
  // devty.ty = (BeckhoffDeviceType.Ty)device_type;
}

int32_t c_enum(int32_t in) {
  const uint32_t device_type = 1;
  enum Example {
    EX0 = 0,
    EX1,
  };
  enum Example ex = in;
  switch (ex) {
    case EX0: {
      return 0;
      break;
    };
    case EX1: {
      return 1;
      break;
    }
  }
}

// Superfluous with C23.
#ifndef GENERATE_ENUM_STRINGS
    #define DECL_ENUM_ELEMENT( element ) element
    #define BEGIN_ENUM( ENUM_NAME ) typedef enum tag##ENUM_NAME
    #define END_ENUM( ENUM_NAME ) ENUM_NAME; \
            char* getString##ENUM_NAME(enum tag##ENUM_NAME index);
#else
    #define DECL_ENUM_ELEMENT( element ) #element
    #define BEGIN_ENUM( ENUM_NAME ) char* gs_##ENUM_NAME [] =
    #define END_ENUM( ENUM_NAME ) ; char* getString##ENUM_NAME(enum \
            tag##ENUM_NAME index){ return gs_##ENUM_NAME [index]; }
#endif
// enum definition
BEGIN_ENUM(OsType)
{
    DECL_ENUM_ELEMENT(WINBLOWS),
    DECL_ENUM_ELEMENT(HACKINTOSH),
} END_ENUM(OsType)
// usage
// getStringOsType(WINBLOWS);


/// taken from boost hash_combine, only ok for <10% of used range, optimized for performance
inline void hash_combine(unsigned long *seed, unsigned long const value)
{
    *seed ^= value + 0x9e3779b9 + (*seed << 6) + (*seed >> 2);
}

// https://github.com/tidwall/th64
// looks like it is not includede in smhasher3 and does not look tiny
static uint64_t th64(const void *data, size_t len, uint64_t seed) {
    uint8_t*p = (uint8_t*)data, *e = p+len;
    uint64_t r = 0x14020a57acced8b7, x, h=seed;
    while(p+8 <= e)
      memcpy(&x, p, 8), x*=r, p+=8, x=x<<31|x>>33, h=h*r^x, h=h<<31|h>>33;
    while(p<e)
      h = h*r^*(p++);
    return(h = h*r+len, h ^= h>>31, h *= r, h ^= h>>31, h *= r, h ^= h>>31, h *= r, h);
}

// TODO siphash for better performance
// https://gitlab.com/fwojcik/smhasher3
// https://github.com/rui314/mold/commit/fa8e95a289f911c0c47409d5848c993cb50c8862

/// assume: continuous data pointed to by str is terminated with 0x00
int32_t Str_Len(const char* str)
{
    const char* tmps = str;
    while(*tmps != 0)
      tmps++;
    return (int32_t)(tmps-str);
}

/// assume: continuous data pointed by input terminated with 0x00
/// assume: str2 has sufficient backed memory size
/// copy strlen chars from str to str2
void Str_Copy(const char* str, int32_t strlen, char* str2)
{
    for(int i=0; i<strlen; i+=1)
        str2[i] = str[i];
}

/// assume: positive number
/// assume: x + y does not overflow
/// computes x/y
int32_t Int_CeilDiv(int32_t x, int32_t y)
{
    return (x + y - 1) / y;
}

// assume: little endian
void printBits(int32_t const size, void * const ptr)
{
    int status = 0;
    unsigned char *b = (unsigned char*) ptr; // generic pointer (void)
    unsigned char byte;
    for (int32_t i = size-1; i >= 0; i-=1)
    {
        for (int32_t j = 7; j >= 0; j-=1)
        {
            unsigned char byte = (b[i] >> j) & 1; // shift ->, rightmost bit
            status = printf("%u", byte);
            if (status < 0) abort(); // stdlib.h
        }
        status = printf("%x", b[i]);
        if (status < 0) abort();
    }
    //printf(" ");
    status = puts(""); // write empty string followed by newline
    if (status < 0) abort();
}

void print_size_t() {
  size_t val = 0;
  printf("%zu\n",val); // SHENNANIGAN clangd: no autocorrection of printf formatter string
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

int f(int* a) {
    *a=*a+1;
    return *a;
}

// SHENNANIGAN
void sequence_points_ub() {
    int a = 0;
    // a = a++ + b++; // Multiple unsequenced modifications to a
    // Same problem without warnings:
    a = f(&a) + f(&a);
}

// SHENNANIGAN
// Aliasing protection in C/C++ is based on type equivalence (in Rust not):
void aliasing_loader_clobberd_by_store(int* a, const int* b) {
  for (int i=0; i<10; i+=1) {
    a[i] += *b;
  }
}

void noaliasing(int* a, const long* b) {
  for (int i=0; i<10; i+=1) {
    a[i] += *b;
  }
}
void noaliasing_with_restrict(int* __restrict__ a, const int* b) {
  for (int i=0; i<10; i+=1) {
    a[i] += *b;
  }
}

// SHENNANIGAN
// Additional pointer semantics created unnecessary UB, so one has to compare
// against 0 to be always compatible.
void ptr_cmp(int* a, const int* b) {
  if (a == 0 && b == 0) {
    *a = *a + *b;
  }
}
// Using this from C is UB:
//   extern C {
//     int* a = nullptr;
//   }
// or using this from C++ is UB:
//   int* a = void*;

// SHENNANIGAN
// No readable, portable simple to use, handling all standard cases for ascii standard
// conversion routines for string to integer. <C++23> is worse without boost.
// This code is uselessly verbose (ignore non-portable printf qualifiers for now) taken from
// https://wiki.sei.cmu.edu/confluence/display/c/ERR34-C.+Detect+errors+when+converting+a+string+to+a+number
// Note, that errno can be set directly.
// #include <errno.h> #include <limits.h> #include <stdlib.h> #include <stdio.h>
void convert_string_to_int(const char *buff) {
  char *end;
  int si;
  errno = 0;
  const long sl = strtol(buff, &end, 10);
  if (end == buff) {
    (void) fprintf(stderr, "%s: not a decimal number\n", buff);
  } else if ('\0' != *end) {
    (void) fprintf(stderr, "%s: extra characters at end of input: %s\n", buff, end);
  } else if ((LONG_MIN == sl || LONG_MAX == sl) && ERANGE == errno) {
    (void) fprintf(stderr, "%s out of range of type long\n", buff);
  } else if (sl > INT_MAX) {
    (void) fprintf(stderr, "%ld greater than INT_MAX\n", sl);
  } else if (sl < INT_MIN) {
    (void) fprintf(stderr, "%ld less than INT_MIN\n", sl);
  } else {
    si = (int)sl;
    // ..
  }
}
void convert_string_to_int_simple(const char *buff) {
  char *end;
  int si;
  errno = 0;
  const long sl = strtol(buff, &end, 10);
  if ( (end != buff) && ('\0' == *end)
    && !((LONG_MIN == sl || LONG_MAX == sl) && ERANGE == errno)
    && (sl >= INT_MIN) && (sl <= INT_MAX)) {
    si = (int)sl;
    // ..
  }
}

// SHENNANIGAN
// create a list data structure implies 3 options:
// * Make it generic using preprocessor directives (boils down to reimplementing or using TODO)
// * Make it generic using 'void *' instead of actual types
// * Not making generic and reimplement for each type.

// SHENNANIGAN
// `malloc(sizeof(MyType) * count)` breaks, if count is not given
// TODO strongly typed C solution
// C++ solution:
// template<typename T>
// __attribute__((malloc)) static inline T * allocate(size_t count) {
//     return reinterpret_cast<T*>(malloc(count * sizeof(T)));
// }

// SHENNANIGAN reinterpret_cast does not exist making different pointer type access UB
// > Dereferencing a pointer that aliases an object that is not of a
// > compatible type or one of the other types allowed by
// > C 2011 6.5 paragraph 71 is undefined behavior.
// => The proper fix for access a pointer with increased alignment is to use a
// temporary with memcopy
int no_reinterpret_cast() {
  //impl_reinterpret_cast_usage
  // clang-format: off
  const char some_vals[9] = { 0
                            , 1, 0, 0, 0
                            , 0, 0, 0 ,0 };
  // clang-format: on
  // WRONG: int64_t val = *((uint64_t*)&some_vals[1]);
  int64_t val;
  // more type safe than reinterpret_cast, because some_vals[1] is a type error
  memcpy(&val, &some_vals[1], 8);
  if (val != INT64_MIN) return 1;
  return 0;
}

// SHENNANIGAN unclear risk from clang/gcc provenance related miscomplations
int ptr_no_reinterpret_cast() {
  char arr[4] = {0,0,0,1};
  int32_t i32_arr = 0;            // unnecessary variable hopefully elided
  memcpy(&i32_arr, &arr[0], 4);
  int32_t * i32_arr_ptr = &i32_arr;
  // SHENNANIGAN dont return stack local variable here!
  return 0;
}

struct sStruct1 {
  uint8_t a1;
  uint8_t a2;
  uint32_t b1;
  uint32_t b2;
};
// Ensure correct storage and padding size for pointers via sizeof.
void padding() {
  struct sStruct1 * str1 = malloc(sizeof(struct sStruct1));
  str1->a1 = 5;
  free(str1);
}

void allowed_aliasing(uint16_t * bytes, int32_t len_bytes, uint16_t * lim) {
  for(int i=0; i<len_bytes; i+=1) {
    if (bytes == lim) break;
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

void printf_align() {
  // pad the input right in a field 10 characters long
  printf("|%-10s|", "Hello");
}

// function pointer example from https://stackoverflow.com/questions/252748/how-can-i-use-an-array-of-function-pointers
int sum(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }
int mul(int a, int b) { return a * b; }
int div_noconflict(int a, int b) { return (b != 0) ? a / b : 0; }

int main() {
    // Array of function pointers initialization
    int (*callbacks[4]) (int, int) = {sum, sub, mul, div_noconflict};

    // Using the function pointers
    int result;
    int i = 20, j = 5, op;

    for (op = 0; op < 4; op++) {
        result = callbacks[op](i, j);
        printf("Result: %d\n", result);
    }

    return 0;
}

// SHENNANIGAN const char* to void* cast has unhelpful error messages
void fn_voidptr(void * raw_ptr, uint16_t len) {
  memset(raw_ptr, 0, len);
}
void use_voidptr() {
	const char *sVars[] = {
		"MAIN.bIn_Overflow",
		"MAIN.bIn_Counter",
  };
  fn_voidptr((void*)sVars[0], strlen(sVars[0]));
}

// SHENNANIGAN standard flag for Windows
// WIN32_LEAN_AND_MEAN
// silently removes deprecated code

// Very aweful, if used withing stdafx.h:
//   #pragma once
//   #include "targetver.h"
//   // Excludes rarely-used stuff from Windows headers
//   #define WIN32_LEAN_AND_MEAN
//   // Windows Header Files:
//   #include <windows.h>

#ifdef _WIN32
// different semantics of "secure fns" and not portable
void ape_win_incompat_fileprint() {
  FILE * f1;
  const char * f1_name = "file1";
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
#endif

// silence clangd warnings
#ifndef _WIN32
#define _CRT_SECURE_NO_WARNINGS
#define _CRT_SECURE_NO_DEPRECATE
void ape_fileprint() {
  const char * f1_name = "file1";
  FILE * f1 = fopen(f1_name, "a+");
  if (f1 == NULL) {
    fprintf(stderr, "cannot open file '%s': %s\n", f1_name, strerror(errno));
  } else {
    fprintf(f1, "some_print_text\n");
    fclose(f1);
  }
}
#endif

#ifdef _WIN32
void ape_win_print() {
  FILE * f1;
  fopen_s(&f1, "file1", "a+");
  fprintf(f1, "sometext\n");
  fclose(f1);
}
#endif

#ifndef _WIN32
void ape_print() {
  FILE * f1 = fopen("file1", "a+");
  fprintf(f1, "sometext\n");
  fclose(f1);
}
#endif

// Less known/arcane/cursed C based on https://jorenar.com/blog/less-known-c
// -Wvla-larger-than=0
// -Wvla
void array_pointers() {
  int arr[10];
  int *ap0 = arr;
  ap0[0] = 5;
  int (*ap1)[10] = &arr;
  (*ap1)[1] = 10;

  // multi-dimensional array on heap
  int (*ap3)[9000][9000] = malloc(sizeof(*ap3));
  if (ap3) free(ap3);

  // Variable Length Array (on stack)
  int (*ap4)[1000][1000] = malloc(sizeof(*ap4));
  if (ap4) {
    // (*arr)[i][j]
    free(ap4);
  }

  // alternative (worse to use): 1d array with offsets, piecewise allocation or big fixed array
  int* arr_1D = malloc(1000 * 1000 * (sizeof(*arr)));
  if (arr_1D) {
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
  int x,y;
  const char * s1;
};

// Designated initializer allow very ugly code, but also reasonable
// array initialization since C99
void designated_initializer() {
  int arr0[] = { 1, 2, [10] = 8, [17] = 9 };
  struct Des1 d1 = { .y = 1, .s1 = "blubb", .x = -1 };
  struct M1 {
    int x;
    int y;
    int z;
  };
  struct M1 arr1[] = {
    [0] = { 0, 1, 9 },
    [1] = { 3, 4, 5 },
    [2] = { 6, 7, 8 },
  };
  struct {
    int sec, min, hour, day, mon, year;
  } dt1 = {
    .day = 1, 1, 2001,
    .sec = 1, 1, 1
  };
}

// Compound literals looks like brace-enclosed initializer list
struct ComLit1 {
  int x, y;
};
void compound_literal(struct ComLit1 cl1) {
  fprintf(stdout, "%d, %d\n", cl1.x, cl1.y);
}
void compound_literal_by_addr(struct ComLit1 * cl1) {
  fprintf(stdout, "%d, %d\n", cl1->x, cl1->y);
}
void compound_literal_usage() {
  // fun fact: red brackets by clangd show that this is cursed
  compound_literal((struct ComLit1){1, 2});
  compound_literal_by_addr(&(struct ComLit1){1, 2});
}

// SHENNANIGAN one can escape shadowing
int x_global_cursed = 13;
void escaping_shadowing() {
  int x = 1;
  {
    extern int x;
    fprintf(stdout, "%d\n", x);
  }
}

// SHENNANIGAN implementation dependent, so best to avoid them
void multi_character_constants() {
  enum State1 {
    Wait = 'WAIT',
    run = 'RUN!',
    stop = 'STOP',
  };
}

// SHENNANIGAN impementation defined behavior for nesting due to being underspecified
void bitfields() {
  struct Bitfield1 {
    unsigned int b0: 3;
    unsigned int b1: 4;
  };
}

// SHENNANIGAN 0 bit field
void zero_bitfield() {
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

// Introduced with C99, few usage example
void flexible_array_member() {
  struct FlexibleArrayMember {
    short len; // at least one other data member
    double arr[]; // flexible array member must be last
    // potential padding
  };
  struct FlexibleArrayMember * flex_arr_mem = malloc(5 * sizeof(struct FlexibleArrayMember));
  flex_arr_mem->len = 5;
  for (uint32_t i = 0; i < flex_arr_mem->len; i += 1)
    flex_arr_mem->arr[i] = 20;
}

void imaginary_cursor_position_in_printf() {
  int pos1, pos2;
  const char * str_unknown_len = "some_string_here";
  fprintf(stdout, "write %n(%s)%n here\n", &pos1, str_unknown_len, &pos2);
  fprintf(stdout, "%*s\\%*s/\n", pos1, " ", pos2-pos1-2, " ");
  fprintf(stdout, "%*s", pos1+1, " ");
}

// TODO finish up https://jorenar.com/blog/less-known-c

#ifdef _linux
void safe_debugging_on_unix() {
  // To see prints, run strace
  write(-1, "writes to non-existing file descriptors are still visible in strace");
}
#endif

#include <stdatomic.h>

// C provides no nice way to get generics (besides C11 non C++ usable generic
// selection), so (usually) it makes no sense to have a method 'update' being
// usable as callback with additional type and runtime safety checks.
// Typical C++ concepts based heavily on operators, constructors and inlined
// templates with non-atomic operations are not automatically applicable.
// Upside: Performance explicit, Downside: more verbose to write get/set
// methods, no good way to use struct generically by filling fn ptr/callback for
// additional method 'update'.
// Omit shared_ptr methods here for brevity.
struct _No_Immutable_in_C_i64 {
  _Atomic int64_t * p1;
  _Atomic int64_t cnt;
};
int32_t immut_set(struct _No_Immutable_in_C_i64 * obj, int64_t val) {
  if (obj != NULL) {
    atomic_store(obj->p1, val);
    return 0;
  }
  return 1;
}
int32_t immut_get(struct _No_Immutable_in_C_i64 * obj, int64_t * val) {
  if (obj != NULL) {
    *val = atomic_load(obj->p1);
    return 0;
  }
  return 1;
}

// based on https://www.chiark.greenend.org.uk/~sgtatham/coroutines.html
// TODO motivation
// Duffs device inspired (case statement is legel within a sub-block
// of its matching switch statement
// TODO

// https://cdacamar.github.io/data%20structures/algorithms/benchmarking/text%20editors/c++/editor-data-structures/
// * gpa buffer
// * rope
// * piece table
// * piece tree
// Research data structure tradeoffs upfront
// Create debug utilities for data structures very early on
// Immutable RB deletion is hard
//
// TODO https://bitbashing.io/gc-for-systems-programmers.html
// basic RCU implementation

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
} s_image_simple;

struct ImageVLA {
  int32_t width;
  int32_t height;
  struct Pixel pixels_vla[];
} ImageVLA;
// TODO align cast in C

// Corresponding zig code:
// const Pixel = externs truct {
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

// SHENNANIGAN snprintf standard specification has ambiguous phrasing on 0 sentinel
// In practive implementations unconditionally add 0 sentinel.
//   if (*errmsg_len > 0) errmsg_ptr[*errmsg_len - 1] = 0x0;
int FG_Init(char * errmsg_ptr, int * errmsg_len) {
  const char * msg = "balbla";
  int st = snprintf(errmsg_ptr, *errmsg_len, "%s", msg);
  if (st > 0) return 0;
  return 1;
}

// TODO pointer alignment in C
//https://blog.quarkslab.com/unaligned-accesses-in-cc-what-why-and-solutions-to-do-it-properly.html
//#include <inttypes.h>
// static inline void * please_align(void * ptr){
//     char * res __attribute__((aligned(128))) ;
//     res = (char *)ptr + (128 - (uintptr_t) ptr) % 128;
//     return res ;
// }
// https://stackoverflow.com/questions/3839922/aligned-malloc-in-gcc
// _mm_alloc, _mm_free

//====signaling on Windows
// TODO better writeup than this
// 3 signal types:
// * APC like IO completion ports which are just things to communicate
// * SEH exceptions first handled by debugger, then VEH exceptions, then SEH exceptions, then frame handler
// * async things which should be only SIGINT and excecuted by passing another thread
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

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
void deinitTimer() {}
void resetOutputs() {}

// SHENNANIGAN windows
// no guide how to minimize headers to optimize compilation time
// only including below things fails in clangd with "No Target Architecture"
// #include <windef.h>
// #include <winnt.h>
LONG __stdcall Exception_Reset(struct _EXCEPTION_POINTERS *ExceptionInfo) {
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
  // TODO: when is the exception executed in each thread?
}

void veh_example() {
	const ULONG prepend = 1;
  // global exception handler executed per thread
	PVOID exception_h = AddVectoredExceptionHandler(prepend, Exception_Reset);
  // local exception handler executed per thread
  // TODO
}
#endif

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

#ifdef _WIN32
// On Windows, Ctrl-C/SIGINT is called from newly spawned thread
// and handled in ConsoleCtrlHandler.
// https://stackoverflow.com/questions/16826097/equivalent-to-sigint-posix-signal-for-catching-ctrlc-under-windows-mingw
BOOL WINAPI ConsoleHandler(DWORD);
BOOL WINAPI ConsoleHandler(DWORD dwType)
{
    switch(dwType) {
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

int setup_SIGINT_handler() {
  if (!SetConsoleCtrlHandler((PHANDLER_ROUTINE)ConsoleHandler,TRUE)) {
    fprintf(stderr, "Unable to install handler!\n");
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
#endif


void getFullPathNameUsage() {
  const char * argv = "test123";
  char *fileExt;
  char szDir[256]; //dummy buffer
  GetFullPathName(&argv[0], 256, szDir, &fileExt);
  printf("Full path: %s\nFilename: %s", szDir, fileExt);
}

//====signaling on Posix
// signal deprecated/undefined, because they have sigprocmask and signal is implementation defined by C standard

// https://maskray.me/blog/2024-05-12-exploring-gnu-extensions-in-linux-kernel
// funny kernel macros and flags to workaround standard issues due to type based aliasing analysis

// delayed loaded via explicit calls to LoadLibrary and GetProcAddress

// #include<windows.h>
// #include<unistd.h>
// Sleep/sleep
