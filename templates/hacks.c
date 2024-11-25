// preload.c
#include <stdint.h>

int isatty(int fd);
int isatty(int fd) {
  switch (fd) {
    case 0: // [[fallthrough]]
    case 1: // [[fallthrough]]
    case 2:
      return 1;
  }
  return 0;
}

// gcc -o preload.so preload.c -shared -fPIC
// LD_PRELOAD=preload.so ls -a &> tmp.txt
// better solution:
// make a fake tty to execute and get outputs with posix_openpty,
// https://devblogs.microsoft.com/commandline/windows-command-line-introducing-the-windows-pseudo-console-conpty/
// ideally sanitizing any escape sequences, which are not color codes.

int32_t main(void) {}
