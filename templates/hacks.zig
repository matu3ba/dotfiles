const std = @import("std");
// print memory of negative number
//std.debug.print("number: {x}\n", .{~(x -% 1)}
// create buffer accessible with slice from string
// better use less indirection (`buf` directly)
//var buf = "d_2".*;
//const bufslice: []u8 = &buf;

//const child_name: [*:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral("child.exe");
//const ch_n = @intToPtr([*:0]u16, @ptrToInt(child_name));
//const ch_n: [*:0]u16 = @ptrCast([*:0]u16, child_name); @ptrCast can not erase const
//0 for inherit handle
//os.windows.CreateProcessW(null, ch_n, null, null, os.windows.TRUE, 0, null, null, &si, &pi) catch |err| {

fn printErrorSet(comptime fun: anytype) void {
    const info = @typeInfo(@TypeOf(fun));
    const ret_type = info.Fn.return_type.?;
    inline for (@typeInfo(@typeInfo(ret_type).ErrorUnion.error_set).ErrorSet.?) |reterror| {
        std.debug.print("{s}\n", .{reterror.name});
    }
}
fn testme() !void {
    const stdout = std.io.getStdOut();
    try stdout.writer().print("testme\n", .{});
}
test "printErrorSet" {
    printErrorSet(testme);
}
//switch(err) {....} inside catch |err| {....} the compiler will yell at you for all unhandled errors
