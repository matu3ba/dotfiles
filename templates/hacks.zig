const std = @import("std");
// print memory of negative number
//std.debug.print("number: {x}\n", .{~(x -% 1)}
// create buffer accessible with slice from string
// better use less indirection (`buf` directly)
//var buf = "d_2".*;
//const bufslice: []u8 = &buf;

//1-item slice via explicit construction
//const node_slice = [1]Ast.Node.Index{datas[node].rhs};
//try stack_decls.append(.{ .nodes = &node_slice, .nodes_i = 0 });

//const child_name: [*:0]const u16 = std.unicode.utf8ToUtf16LeStringLiteral("child.exe");
//const ch_n = @intToPtr([*:0]u16, @ptrToInt(child_name));
//const ch_n: [*:0]u16 = @ptrCast([*:0]u16, child_name); @ptrCast can not erase const, use @constCast
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

pub fn printErrorSet2() void {
    const e = @field(anyerror, "NotFound");
    std.debug.print("{}\n", .{@TypeOf(e)});
}
//switch(err) {....} inside catch |err| {....} the compiler will yell at you for all unhandled errors

fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}
// usage (i will increment from 0->9):
//for (range(10)) |_, i| { ... }

//const nums = [3]usize {42, 42, 42};
//const chars = [3]u8 {'a', 'b', 'c'};
// easy "zip" iteration (all arguments must have the same length)
//for (nums, chars) |n, c| { ... }
// easy range loops
//for (0..3) |idx| { ... } /
// but this won't work anymore (old syntax)
//for (chars) |c, idx| { ... }
// now you need a range if you want an index
//for (chars, 0..) |elem, idx| { ... }

// switch on union field
const Self = struct {
    fn get(self: Self, comptime field: @Type(.EnumLiteral)) ?std.meta.fieldInfo(Self, field).field_type {
        if (self != field) return null;
        return @field(self, @tagName(field));
    }
};

// workaround zig libstd bloated formatting:
// https://github.com/FlorenceOS/Florence/blob/master/lib/output/fmt.zig

// example for how to hack around or use optional slice?[LEN]u8)
fn memcpyslice() void {
    const LEN = 100;
    var msg: ?[LEN]u8 = null;
    const src = "somemsg";
    const src_len = src.len;
    msg = .{undefined} ** LEN;
    @memcpy(msg.?[0..src_len], "somemsg");
    std.debug.print("msg: {?s}\n", .{msg});
}
