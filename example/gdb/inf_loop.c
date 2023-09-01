//! Infinity loop to examplify gdb and VS Debugger usage
#include <stdbool.h> // bool
#include <inttypes.h> // PRIu64, uint64_t (stdint.h not needed)
#include <stdio.h> // printf
#include <unistd.h> // sleep

// To fix permission problems, see PERMISSIONS in ../../templates/gdb
// Usage:
// - 1. gcore to dump running process memory state via ptrac
// mkdir -p build/ && clang -g inf_loop.c -o build/inf_loop && ./build/inf_loop
// PID=$(pgrep inf_loop) && sudo gcore -a -o core "${PID}" && gdb ./build/inf_loop "core.${PID}"
// gdb ./build/inf_loop corefile
// - 2. attach to running process
// PID=$(pgrep inf_loop) && gdb -p "${PID}"
// PID=$(pgrep inf_loop) && sudo -E capsh --caps="cap_setpcap,cap_setuid,cap_setgid+ep cap_sys_ptrace+eip" --keep=1 --user="$USER" --addamb="cap_sys_ptrace" --shell=/usr/bin/gdb -- -p "${PID}" ./build/inf_loop
//   This typically halts the process
// - 3. detecting infinite loop and conditions
// gdb -ex run ./build/inf_loop
// - 4. prevent internal timer firing to kill process TODO
//   See also https://stackoverflow.com/questions/3270281/can-gdb-make-a-function-pointer-point-to-another-location
//   * 4.1 dll injection
//   * 4.2 LD_PRELOAD
//   * 4.3 'function instrumentation hocks'
//   * 4.4 see '5.4 Signals' in gdb manual

int main() {
    uint64_t runtime = 0;
    uint64_t sleeptime = 1;

    while ( true ) {
        sleep(sleeptime);
        runtime += sleeptime;
        printf("%" PRIu64 "\n", runtime);
    }
}
