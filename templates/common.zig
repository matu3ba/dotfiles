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

