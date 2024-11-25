const std = @import("std");
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const res = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "/usr/bin/sudo", "/usr/bin/groupadd", "test123123" },
    }) catch {
        return error.CouldNotRunShellExplicit;
    };
    _ = res;
}
