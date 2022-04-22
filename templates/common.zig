const std = @import("std");

// typesafe version of (u16*)codepoint with codepoint type u8*
// codepoint created from Utf8View which is [_]u8
const char = std.mem.bytesAsValue(u16, codepoint[0..2]); // U+0080...U+07FF

const factorial_lookup_table = createFactorialLookupTable(u128, 25);
pub fn createFactorialLookupTable(comptime Int: type, comptime num_terms: comptime_int) [num_terms]Int {
    if (@typeInfo(Int) != .Int) {
        @compileError("Data type of terms must be of an integer type. Got '" ++ @typeName(Int) ++ "'.");
    }
    var table: [num_terms]Int = undefined;
    table[0] = 1;
    for (table[1..]) |*entry, i| {
        entry.* = std.math.mul(Int, table[i], i + 1) catch {
            @compileError("Int type too small for the number of factorial terms specified.");
        };
    }
    return table;
}
// usage: std.debug.print("{any}\n", .{factorial_lookup_table});

fn CreateStructType(comptime T: type) type {
    if(@sizeOf(T) == 64) {
        return struct {
            t1: T,
        };
    } else {
        return struct {
            t1: T,
            t2: T,
        };
    }
}

pub fn main() !void {
    var path_buffer: [1000]u8 = undefined;
    var n_pbuf: u64 = 0; // next free position
    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();
    const args: [][:0]u8 = try std.process.argsAlloc(arena);
    defer std.process.argsFree(arena, args);
    for (args) |arg| {
        std.debug.print("{s}\n", .{arg});
    }
    std.mem.copy(u8, path_buffer[n_pbuf..], args[1]);
    n_pbuf += args[1].len;

    // alternative:
    var it = try std.process.argsWithAllocator(arena);
    defer it.deinit(); // no-op unless WASI or Windows
    _ = it.next(); // ignore binary name
    const str_ip = it.next().?;
    const str_port = it.next().?;
    try std.testing.expect(!it.skip());
    _ = str_ip;
    _ = str_port;
}
