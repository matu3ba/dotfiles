#ifndef __cplusplus // disable clang complains
#pragma once
#include <stdint.h> // abi: uint32_t, uint8_t
#include <stdlib.h> // assert: exit
#include <stdio.h>  // assert: fprintf

// Maro expansion once for validity yields in slightly more ugly code and unused
// value warning, so omit it. See link for discussion.
#define STRINGIFY(A) ((A),STRINGIFY_INTERN(A))
#define PPCAT(A) ((A),(B),PPCAT_INTERN(A,B))
// and do instead
#define STRINGIFY_INTERN(A) (#A)
#define STRINGIFY(A) STRINGIFY_INTERN(A)
#define PPCAT_INTERN(A,B) A ## B
#define PPCAT(A,...) PPCAT_INTERN(A,__VA_ARGS__)
#define COMBINE(WORD,...) STRINGIFY(PPCAT(WORD,__VA_ARGS__))
#define test0 testme
#define test1 1
#define RESULT COMBINE(test0, test1)
#define emptystr ""
#define test2 testme2

void printbanana(const char* str) {
    printf("t2: %s\n", str);
}
int usage_ppcat() {
    const char* testme1 = "banana";
    const char* testme2 = "bestbanana";
    printf("t1: %s\n", COMBINE(test0, test1)); // t1: testme1
    printbanana(PPCAT(test0, test1)); // t1: testme1
    printbanana(PPCAT(test2)); // t2: bestbanana
    return 0;
}
// see also https://stackoverflow.com/questions/1644868/define-macro-for-debug-printing-in-c/1644898#1644898

#ifdef TRUE
#error "TRUE already defined"
#else
#define TRUE (1==1)
#endif

#ifdef FALSE
#error "False already defined"
#else
#define FALSE (!TRUE)
#endif

// existence of typedefs can not be checked within macros
//#define _TYPEDEF_
typedef enum { false = FALSE, true } bool;
//#endif

// potential necessity: custom printf and exit for the platform
// unfortunately we dont have __COLUMN__ as macro
#define assert(a) if( !( a ) )                            \
{                                                         \
    fprintf( stderr, "%s:%d assertion failure of (%s)\n", \
                             __FILE__, __LINE__, #a );    \
    exit( 1 );                                            \
}                                                         \
_Static_assert(true, "")

#ifdef static_assert
#error "static_assert already defined"
#else
#define static_assert _Static_assert // since C11
#endif

#ifdef IS_SIGNED
#error "IS_SIGNED already defined"
#else
#define IS_SIGNED(Type) (((Type)-1) < 0)
#endif


_Static_assert(IS_SIGNED(char),   "err: char is unsigned");
_Static_assert(sizeof(char) == 1, "err: char not 1 byte");
_Static_assert(sizeof(unsigned char) == 1, "err: char not 1 byte");
_Static_assert(sizeof(signed char) == 1, "err: char not 1 byte");
_Static_assert(sizeof(uint8_t) == 1,  "err: uint8_t not 1 byte");
_Static_assert(sizeof(uint16_t) == 2, "err: uint16_t not 2 byte");
_Static_assert(sizeof(uint32_t) == 4, "err: uint32_t not 4 byte");
_Static_assert(sizeof(uint64_t) == 8, "err: uint64_t not 8 byte");
_Static_assert(sizeof(int8_t) == 1,  "err: int8_t not 1 byte");
_Static_assert(sizeof(int16_t) == 2, "err: int16_t not 2 byte");
_Static_assert(sizeof(int32_t) == 4, "err: int32_t not 4 byte");
_Static_assert(sizeof(int64_t) == 8, "err: int64_t not 8 byte");
//_Static_assert(sizeof(uint128_t) == 16, "err: uint128_t not 16 byte"); // poorly supported
//_Static_assert(sizeof(int128_t) == 16, "err: int128_t not 16 byte"); // poorly supported

// C11's Generic selection: Return constant 1, if type and 0 otherwise
// Keep things clean via stringification
#define STATIC_ASSERT_H(x)  _Static_assert(x, #x)
#define STATIC_ASSERT(x)    STATIC_ASSERT_H(x)
#define OBJ_IS_OF_TYPE(Type, Obj) _Generic(Obj, Type: 1, default: 0)
// Note: C++11 has other utilities and is incompatible with _Static_assert
// #include <type_traits>
// #define OBJ_IS_OF_TYPE(Type, Obj) std::is_same<decltype(Obj), Type>::value
// #define STATIC_ASSERT(Input) static_assert(Input)
// { Usage
//     #include <time.h>
//     STATIC_ASSERT(OBJ_IS_OF_TYPE(timespecval1.tv_sec, int64_t));
//     STATIC_ASSERT(OBJ_IS_OF_TYPE(timespecval1.tv_nsec, int64_t));
// }
// Hygienic macros
#define TEST_FUNC(a,b)                                         \
do {                                                           \
    STATIC_ASSERT(OBJ_IS_OF_TYPE(a, int64_t));                 \
    STATIC_ASSERT(OBJ_IS_OF_TYPE(b, int64_t));                 \
} while(0)

#define add(...) _Generic ( &(int[]){__VA_ARGS__}, \
                            int(*)[2]: add2,       \
                            int(*)[3]: add3) (__VA_ARGS__)
int add2 (int a, int b);
int add3 (int a, int b, int c);
int add_typesafe_generic_selection_c11 (void) {
  printf("%d\n", add(1, 2));
  printf("%d\n", add(1, 2, 3));
  //printf("%d\n", add(1, 2, 3, 4)); Compiler error for this.
}
int add2 (int a, int b) { return a + b; }
int add3 (int a, int b, int c) { return a + b + c; }

#endif // __cplusplus

// idea ifdef error else define macro to make macros shorter
// use typedef, if possible: prevents `short SHORTINT test = 1;` shennanigans.

// figure out default symbols of host
// echo | gcc -dM -E -

// TODO
// tldr; https://airbus-seclab.github.io/c-compiler-security/
// in-depth https://github.com/airbus-seclab/c-compiler-security

// Survival flags
// -Wno-shadow -Wno-switch-enum -Wno-missing-prototypes
// -Wno-unknown-pragmas -Wno-unused-parameter
// -fsanitize=unsigned-integer-overflow (must be separate, because it breaks C standard, unlike -ftrapv this one actually works)
// -fsanitize=undefined
// -Wstring-conversion

// Check during development specifically clang -Weverything

// CLANG_TIDY_FLAGS="clang-*,cppcoreguidelines-*,modernize-*,performance-*"
// clang-tidy \
//   -checks="$CHECKS" \
//   -header-filter="$H*" $file \
//   -- \
//   -std=c++1z \
//   -D_REENTRANT -fPIC \
//   $WARN $DEFINES $INCLUDES

// C/C++ mixing survival guide
// 1. Add -Wstring-conversion and either 1. handle char* in callee fns or 2. always pass std::string family
// 2. Use std::string or memory-managing containers in callee fns or document lifetime explicitly.
// 3. Always initialize within managed containers xor delete default constructors
