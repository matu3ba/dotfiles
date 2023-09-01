#include <inttypes.h> // PRIu64
#include <stdio.h> // printf
// since c++11 usable with #include <cinttypes>
// and with abs, quotient, remainder, conversion of byte string and wide string to
// intmax_t and uintmax_t

// For embedded C, use https://github.com/mpaland/printf or https://github.com/eyalroz/printf

int main() {
    // https://en.cppreference.com/w/cpp/types/integer
    printf("%zu\n", sizeof(int64_t));
    printf("%s\n", PRId64);
    printf("%+" PRId64 "\n", INT64_MIN);
    printf("%+" PRIi64 "\n", INT64_MIN);  // INT64_MAX
    int64_t n = 7;
    printf("%+" PRId64 "\n", n);

    // https://en.cppreference.com/w/c/io/fprintf
    const char* s = "Hello";
    printf("Strings:\n"); // same as puts("Strings");
    printf(" padding:\n");
    printf("\t[%10s]\n", s);
    printf("\t[%-10s]\n", s);
    printf("\t[%*s]\n", 10, s);
    printf(" truncating:\n");
    printf("\t%.4s\n", s);
    printf("\t%.*s\n", 3, s);

    printf("Characters:\t%c %%\n", 'A');

    printf("Integers:\n");
    printf("\tDecimal:\t%i %d %.6i %i %.0i %+i %i\n",
                         1, 2,   3, 0,   0,  4,-4);
    printf("\tHexadecimal:\t%x %x %X %#x\n", 5, 10, 10, 6);
    printf("\tOctal:\t\t%o %#o %#o\n", 10, 10, 4);

    printf("Floating point:\n");
    printf("\tRounding:\t%f %.0f %.32f\n", 1.5, 1.5, 1.3);
    printf("\tPadding:\t%05.2f %.2f %5.2f\n", 1.5, 1.5, 1.5);
    printf("\tScientific:\t%E %e\n", 1.5, 1.5);
    printf("\tHexadecimal:\t%a %A\n", 1.5, 1.5);
    printf("\tSpecial values:\t0/0=%g 1/0=%g\n", 0.0/0.0, 1.0/0.0);

    printf("Largest 32 bit value is %" PRIu64 " or %#" PRIx32 "\n", UINT32_MAX, UINT32_MAX);
}
