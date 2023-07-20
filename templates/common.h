#ifndef __cplusplus // disable clang complains
#pragma once
#include <stdint.h> // abi: uint32_t, uint8_t
#include <stdlib.h> // assert: exit
#include <stdio.h>  // assert: fprintf

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

#endif // __cplusplus

// idea ifdef error else define macro to make macros shorter
// use typedef, if possible: prevents `short SHORTINT test = 1;` shennanigans.
