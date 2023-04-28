const std = @import("std");
const builtin = @import("builtin");

// typesafe version of (u16*)codepoint with codepoint type u8*
// codepoint created from Utf8View which is [_]u8
// const char = std.mem.bytesAsValue(u16, codepoint[0..2]); // U+0080...U+07FF
// const char2 = @bitCast(u16, arr[idx..][0..2].*);

// String shorthand conversions => &. and &[_][]const u8
// builder.pathJoin(&[_][]const u8 { "foo", "bar", "baz"})
// builder.pathJoin(&.{ "foo", "bar", "baz"})

const factorial_lookup_table = createFactorialLookupTable(u128, 25);
pub fn createFactorialLookupTable(comptime Int: type, comptime num_terms: comptime_int) [num_terms]Int {
    if (@typeInfo(Int) != .Int) {
        @compileError("Data type of terms must be of an integer type. Got '" ++ @typeName(Int) ++ "'.");
    }
    var table: [num_terms]Int = undefined;
    table[0] = 1;
    for (table[1..], 0..) |*entry, i| {
        entry.* = std.math.mul(Int, table[i], i + 1) catch {
            @compileError("Int type too small for the number of factorial terms specified.");
        };
    }
    return table;
}
// usage: std.debug.print("{any}\n", .{factorial_lookup_table});

fn CreateStructType(comptime T: type) type {
    if (@sizeOf(T) == 64) {
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

fn maxAsciiDigits(comptime UT: type) u64 {
    return std.fmt.count("{d}", .{std.math.maxInt(UT)});
}
// ie for struct CtrlMsg with field testnr we can get the type with:
//const maxsize_testnr: u64 = maxAsciiDigits(std.meta.fieldInfo(CtrlMsg, .testnr).field_type);

fn masking() !void {
    var sigabrtmask = std.bit_set.ArrayBitSet(u32, @typeInfo(std.os.sigset_t).Array.len);
    comptime sigabrtmask.initEmpty();
    comptime sigabrtmask.set(std.os.SIG.ABRT);
    std.os.sigprocmask(std.os.SIG.UNBLOCK, &sigabrtmask, null);
}

//const unidirect = std.meta.activeTag(extra.parent) != std.meta.activeTag(extra.child);

fn arraybitset() void {
    comptime var sigabrtmask_bitset = std.bit_set.ArrayBitSet(u32, @typeInfo(std.os.sigset_t).Array.len).initEmpty();
    var sigabrtmask: std.os.system.sigset_t = undefined;
    comptime sigabrtmask_bitset.set(std.os.SIG.ABRT);
    inline for (sigabrtmask_bitset.masks, 0..) |mask, i|
        sigabrtmask[i] = mask;
    std.os.sigprocmask(std.os.SIG.UNBLOCK, &sigabrtmask, null);
}

// std.sort.sort(TokenRange, skiplist.items, {}, sortTokenRange);
//pub fn sortTokenRange(context: void, a: TokenRange, b: TokenRange) bool {
//    _ = context;
//    return a.start < b.start;
//}

// using artefact without insalling
pub fn buildCommon(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();
    const child = b.addExecutable("child", "child.zig");
    child.setBuildMode(mode);
    const main_exec = b.addExecutable("main", "main.zig");
    main_exec.setBuildMode(mode);
    const run = main_exec.run();
    // addArtifactArg
    run.addArtifactArg(child);
    const test_step = b.step("test", "Test it");
    test_step.dependOn(&run.step);
}

// combine file paths into buffer
fn usageCombinePaths() !void {
    var path_buffer: [1000]u8 = undefined;
    const input1 = "/tmp";
    const number: usize = 15;
    const input2 = "file.zig";
    _ = try std.fmt.bufPrint(path_buffer, "{s}{d}{s}", .{ input1, number, input2 });
}

// sort items with context
const TokenRange = struct {
    start: usize,
};
pub fn sortTokenRange(context: *std.ArrayList(TokenRange), a: usize, b: usize) bool {
    return context.items[a].start < context.items[b].start;
}
fn usageSortContext() void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!general_purpose_allocator.deinit());
    const gpa = general_purpose_allocator.allocator();

    var skiplist = std.ArrayList(TokenRange).initCapacity(gpa, 1);
    defer skiplist.deinit();
    var skipl_index = try std.ArrayList(usize).initCapacity(gpa, 1);
    defer skipl_index.deinit();
    std.sort.sort(usize, skipl_index.items, &skiplist, sortTokenRange);
}

fn usageFBA() void {
    var cmdline_buffer: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&cmdline_buffer);
    const args = std.process.argsAlloc(fba.allocator()) catch
        @panic("unable to parse command line args");
    _ = args;
}

// explicit error set
fn somefunction() error{ErrName}!void {}

const reserved_size = 4 * std.mem.page_size;
var testblock_buffer: [reserved_size]u8 = undefined;
var fixedbuf_decl = std.heap.FixedBufferAllocator.init(&testblock_buffer);
const testblock_alloc = fixedbuf_decl.allocator();

const Cli = struct {
    test_runner_exe_path: []u8,
};

fn processArgs(static_alloc: std.mem.Allocator) Cli {
    const args = std.process.argsAlloc(static_alloc) catch {
        @panic("Too many bytes passed over the CLI to Test Runner/Control.");
    };
    return .{
        .test_runner_exe_path = args[0],
    };
}

fn debugCwd(alloc: std.mem.Allocator) void {
    const cwdstr = std.process.getCwdAlloc(alloc) catch unreachable;
    defer alloc.free(cwdstr);
    std.log.debug("cwd: '{s}'", .{cwdstr});
}

// conditional emitting of global symbol
const VarT = if (!builtin.is_test) u32 else void;
threadlocal var v1: VarT = if (!builtin.is_test) 0 else void;

// in build.zig use -D (as desribed in zig build -h)
// zig build test-standalone -Dtest-filter=childprocess_extrapipe --zig-lib-dir lib
// Otherwise for libstd tests, use
// zig test lib/std/fmt.zig --zig-lib-dir lib --main-pkg-path lib/std

fn simpleCAS() !void {
    const Available = enum(u8) {
        NotStarted,
        Started,
        Finished,
    };
    var available: Available = .NotStarted;
    // type, ptr_checked, expect .NotStarted, new_value .Started
    // if expect satisfied => apply new value + return null
    //           otherwise => no value applied, retun old value in available
    const state = @cmpxchgStrong(Available, &available, .NotStarted, .Started, .SeqCst, .SeqCst) orelse return null;
    switch (state) {
        .NotStarted => unreachable, // can not be .Notstarted
        .Started => std.log.debug("ok"),
        .Finished => std.log.debug("no need to start again"),
    }
}
