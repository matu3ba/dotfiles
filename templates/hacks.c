// MACROS
#define IS_SIGNED(Type) (((Type)-1) < 0)

#include <assert.h>
static_assert(sizeof(U8) == 1, "U8 must have 1 byte size"); // compile-time error

// http://scaryreasoner.wordpress.com/2009/02/28/checking-sizeof-at-compile-time/
#define BUILD_BUG_ON(condition) ((void)sizeof(char[1 - 2*!!(condition)]))
usage: BUILD_BUG_ON( sizeof(someThing) != PAGE_SIZE );

// RUNTIME
// sets status to 3 even though %d and %x are no string specifiers
// status = printf("%d%x\n", 0, 0);
// for sensitive code, use the following or fix the bad printf behavior with own implementation:
if(number != 0)
    status = printf("%d%x\n", 0, 0);
else
    printf("%d%x\n", 0, 0);

// assume: little endian
void printBits(TYPE const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;
    for (i = size-1; i >= 0; i--) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte); // might need more portable print method
        }
    }
    puts("");
}
