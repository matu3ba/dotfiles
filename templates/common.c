#include <stdint.h> // uint32_t, uint8_t
#include <stdlib.h> // exit
#include <stdio.h>  // fprintf

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
