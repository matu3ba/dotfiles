//! convention:
//! * main.zig has main fn is for building an executable
//! * root.zig is for building a library
const std = @import("std");

pub fn main() !void {
    // shortcut based `std.io.getStdErr()
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for app output, for example a gzip implementation should
    // send compressed bytes to stdout and not any debugging messages
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush(); // after dumping messages, flush them
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    // commenting out below linne for leak checks
    defer list.deinit();
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // for fuzzing, try 'zig build test --fuzz'
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}
