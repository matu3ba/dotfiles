//! Infinity loop to examplify gdb and VS Debugger usage
#include <stdbool.h> // bool
#include <inttypes.h> // PRIu64, uint64_t (stdint.h not needed)
#include <stdio.h> // printf
#include <unistd.h> // sleep

// Usage:
// clang inf_loop.c -o build/inf_loop && ./build/inf_loop
//
//
//
//
//
//

int main() {
    uint64_t runtime = 0;
    uint64_t sleeptime = 1;

    while ( true ) {
        sleep(sleeptime);
        runtime += sleeptime;
        printf("runtime: %" PRIu64 "\n", runtime);
    }
}
