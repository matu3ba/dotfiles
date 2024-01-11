#include <stdint.h> // uint32_t, uint8_t
#include <stdlib.h> // exit
#include <stdio.h>  // fprintf
#include <errno.h>  // errno
#include <limits.h> // limit
#include <string.h> // memcpy

// Standards
// http://port70.net/~nsz/c/

// In short: Pointers are a huge footgun in C standard.
//
// The proper fix for access a pointer with increased alignment is to use a
// temporary with memcopy
// https://stackoverflow.com/questions/7059299/how-to-properly-convert-an-unsigned-char-array-into-an-uint32-t.
// To only compare pointers decrease alignment with char* pointer.
// To prune type info for generics use void* pointer. HOWEVER, you are
// responsible to call a function that provides or provide yourself
// 1. proper alignment, 2. sufficient storage and 3. if nececssary
// sufficient padding (ie within structs), 4. correct aliasing.
// "Strict Aliasing Rule"
// > Dereferencing a pointer that aliases an object that is not of a
// > compatible type or one of the other types allowed by
// > C 2011 6.5 paragraph 71 is undefined behavior.
//
// Except, by posix extension: casting pointers to functions (and back), because
// that must be valid for dynamic linking etc.

// macro NULL = 0 or mingw null

// TODO code example

// Might get superfluous with new C standard (C2x).
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
getStringOsType(WINBLOWS);


/// taken from boost hash_combine, only ok for <10% of used range, optimized for performance
inline void hash_combine(unsigned long *seed, unsigned long const value)
{
    *seed ^= value + 0x9e3779b9 + (*seed << 6) + (*seed >> 2);
}

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
void workaround_no_reinterpret_cast() {
  char arr[4] = {0,0,0,1};
  int32_t i32_arr = 0;
  memcpy(&i32_arr, &arr[0], 4);
  int32_t * i32_arr_ptr = &i32_arr;
}

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
}

// Non-trivial C
// https://zackoverflow.dev/writing/how-to-actually-write-c
// https://zackoverflow.dev/writing/premature-abstraction

void printf_align() {
  // pad the input right in a field 10 characters long
  printf("|%-10s|", "Hello");
}
