//! 4.1 LD_PRELOAD
//! Purpose is to do static and hacky replacements of shared objects
//! functionality.
//! Stolen from https://www.themetabytes.com/2017/11/25/ld_preload-hacks/
//! TODO
//! - convert to Zig for portability across Unixes

// Base Usage: gcc ./adv/ld_preload.c -o ./build/rand && ./build/rand
// use //==1_simple
//   gcc -DUSAGE=1 -fPIC -shared ./adv/ld_preload_replacements.c -o ./build/const_rand.so
//   cd ./build/ && LD_PRELOAD=./const_rand.so ./rand ; cd ..
//   LD_LIBRARY_PATH=./build/ LD_PRELOAD=$PWD/build/const_rand.so ./build/rand
// use //==2_advanced:
//   gcc -DUSAGE=2 -fPIC -shared ./adv/ld_preload_replacements.c -o ./build/redirect_printf.so
//   cd ./build/ && LD_PRELOAD=./redirect_printf.so ./rand ; cd ..
//   LD_LIBRARY_PATH=./build/ LD_PRELOAD=$PWD/build/redirect_printf.so ./build/rand
// combine both:
//   cd ./build/ && LD_PRELOAD=./build/const_rand.so:./redirect_printf.so ./rand ; cd ..
//   LD_LIBRARY_PATH=./build/ LD_PRELOAD=$PWD/build/const_rand.so:$PWD/build/redirect_printf.so ./build/rand
// More advanced: gcc -DUSE_SIGNAL ./adv/ld_preload.c -o ./build/sigsev && ./build/sigsev
// use //==3_signal_handler
//   gcc -DUSAGE=3 -fPIC ./adv/ld_preload_replacements.c -c -o ./build/handler.o
//   // work around _init name clash
//   ld -shared ./build/handler.o -o ./build/handler.so
//   cd ./build/ && LD_PRELOAD=./build/handler.so ./sigsev ; cd ..
//   LD_LIBRARY_PATH=./build/ LD_PRELOAD=$PWD/build/handler.so ./build/sigsev

// The same things also work at load time, ie via linker dependencies and preloaded
// libraries can wait for other libraries to be initialized.
// gcc -shared  -fPIC -Wl,-init,init  -ldl comm.c -o comm.so
// https://stackoverflow.com/questions/49226864/why-is-library-loaded-via-ld-preload-operating-before-initialization

#ifndef USE_SIGNAL
#include <stdbool.h> // bool
#include <inttypes.h> // PRIu64, uint64_t (stdint.h not needed)
#include <stdio.h> // printf
#include <unistd.h> // sleep
#include <time.h>
#include <stdlib.h>
int main() {
    srand(time(NULL));
    int32_t i = 10;
    while(i > 0) {
        i -= 1;
        printf("% " PRId32 "\n",rand() % 100);
    }
    return 0;
}
#else
#include <stdio.h>
#include <stdlib.h>
int main() {
    printf("it goes downhill from here ...\n");
    int i = *(int*)0;
    return 0;
}
#endif
