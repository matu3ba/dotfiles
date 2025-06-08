pub const comptime_allocator: Allocator = .{
    .ptr = undefined,
    .vtable = &.{ .alloc = &comptimeAlloc, .resize = &comptimeResize, .remap = &comptimeRemap, .free = &Allocator.noFree },
};

fn comptimeAlloc(_: *anyopaque, len: usize, alignment: Alignment, ra: usize) ?[*]u8 {
    _ = ra;
    if (!@inComptime()) @panic("comptimeAlloc called at runtime");
    var buf: [len]u8 align(alignment.toByteUnits()) = undefined;
    return &buf;
}

fn comptimeResize(_: *anyopaque, mem: []u8, alignment: Alignment, new_len: usize, ra: usize) bool {
    _ = alignment;
    _ = ra;
    if (!@inComptime()) @panic("comptimeResize called at runtime");
    return new_len <= mem.len; // allow shrinking in-place
}

fn comptimeRemap(_: *anyopaque, mem: []u8, alignment: Alignment, new_len: usize, ra: usize) ?[*]u8 {
    _ = alignment;
    _ = ra;
    if (!@inComptime()) @panic("comptimeRemap called at runtime");
    return if (new_len <= mem.len) mem.ptr else null; // allow shrinking in-place
}

comptime {
    var al: std.ArrayListUnmanaged(u32) = .empty;
    defer al.deinit(comptime_allocator);

    al.appendSlice(comptime_allocator, &.{ 1, 2, 3 }) catch unreachable;
    al.appendNTimes(comptime_allocator, 42, 256) catch unreachable;

    std.debug.assert(al.items.len == 256 + 3);
    std.debug.assert(al.items[0] == 1);
    std.debug.assert(al.items[1] == 2);
    std.debug.assert(al.items[2] == 3);
    for (al.items[3..]) |x| {
        std.debug.assert(x == 42);
    }
}

const std = @import("std");
const Allocator = std.mem.Allocator;
const Alignment = std.mem.Alignment;

// stub for compilation check
pub fn main() void {}
