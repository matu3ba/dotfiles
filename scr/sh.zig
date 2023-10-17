//usr/bin/env zig run --global-cache-dir "/tmp/zigruns" --enable-cache "$0" -- "$@" | tail -n +2; exit
// ^
// for no cache dir printed.
// with cache dir:
//usr/bin/env zig run --global-cache-dir "/tmp/zigruns" --enable-cache "$0" -- "$@"; exit
// without cache dir:
//usr/bin/env zig run "$0" -- "$@"; exit

// Only works with files with file ending .zig

pub fn main() void {
    @import("std").debug.print("hello there\n", .{});
}

// old hack for running zig compiler on document: ///usr/bin/env -S zig run
