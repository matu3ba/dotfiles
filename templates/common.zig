const std = @import("std");
const builtin = @import("builtin");

// Tools (common vs special)
// kcov - https://github.com/liyu1981/kcov
// tracy - https://github.com/wolfpld/tracy
// cova(cli args) - https://github.com/00JCIV00/cova
// rizin(reverse engineering) - https://github.com/rizinorg/rizin
// orbit(tracing no annotation) - https://github.com/google/orbit

// Tools windows
// raddebugger - https://github.com/EpicGames/raddebugger
// system analysis tool - https://github.com/winsiderss/systeminformer
// dll dependencies - https://github.com/lucasg/Dependencies
// ntrace - https://github.com/rogerorr/NtTrace

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
    const path_buffer: [1000]u8 = undefined;
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
// Typical flags: -fwasmtime -fqemu -freference-trace -lc -Dtarget=x86_64-windows-gnu
// zig build test-standalone -Dtest-filter=childprocess_extrapipe --zig-lib-dir lib
// zig build test-std -Dtest-filter="getDefaultPageSize smoke test" -fqemu --zig-lib-dir lib
// Otherwise for libstd tests, use
// zig test lib/std/fmt.zig --zig-lib-dir lib --main-pkg-path lib/std
// zig test C:\cygwin64\home\kcbanner\kit\zig\lib\std\std.zig -target x86_64-windows-gnu -mcpu x86_64 -I C:\cygwin64\home\kcbanner\kit\zig\test --zig-lib-dir C:\cygwin64\home\kcbanner\kit\zig\lib --test-filter "DWARF expressions"
// zig test .\lib\std\std.zig -target x86_64-windows-gnu -mcpu x86_64 -I .\test --zig-lib-dir .\lib --test-filter "DWARF expressions"
// zig test ./lib/std/std.zig -target x86_64-windows-gnu -mcpu x86_64 -I ./test --zig-lib-dir ./lib --test-filter "DWARF expressions"
// zig test ./lib/std/std.zig  -I ./test --zig-lib-dir ./lib --test-filter "getPageSize smoke test"
// zig test lib/std/std.zig --zig-lib-dir lib --main-pkg-path lib/std --test-filter "your test name"
// zig test lib/std/std.zig --test-filter "your test name"
// Run tests within valgrind via:
// zig test valgrind.zig -lc --test-cmd valgrind --test-cmd '-s' --test-cmd-bin
// Run tests within qemu:
// zig test qemu.zig -target aarch64-linux-none --test-cmd qemu-aarch64 --test-cmd-bin
// Run tests within qemu + debugger:
// zig test lib/compiler_rt/udivmoddi4_test.zig -target arm-linux --test-cmd qemu-arm --test-cmd -g --test-cmd 4242 --test-cmd-bin

// Testing with wasm+wasmtime:
// WASMTIME_BACKTRACE_DETAILS=1 ./deb/bin/zig test ./lib/std/std.zig -target wasm32-wasi -I ./test --zig-lib-dir lib/  --test-cmd wasmtime --test-cmd --dir=. --test-cmd-bin

// SHENNANIGAN Bootstrapping and checking methods is very time consuming
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows"
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows" -DZIG_TARGET_MCPU=baseline
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-gnu"
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-gnu" -DZIG_TARGET_MCPU=baseline
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-msvc"
// cmake .. -G "Ninja" -DCMAKE_PREFIX_PATH="../../zig-bootstrap/master/out-win/host/" -DCMAKE_BUILD_TYPE=Release -DZIG_STATIC=ON -DZIG_STATIC_ZSTD=OFF -DZIG_TARGET_TRIPLE="x86_64-windows-msvc" -DZIG_TARGET_MCPU=baseline
// cmake --build . --target install

// Common targets:
// native-native-musl
// aarch64-linux-gnu
// aarch64-linux-musl
// aarch64-linux-none
// x86_64-linux-gnu
// x86_64-linux-musl
// x86_64-linux-none
// aarch64-macos
// aarch64-macos-none
// x86_64-macos
// x86_64-macos-none
// aarch64-windows
// aarch64-windows-gnu
// aarch64-windows-none
// x86_64-windows
// x86_64-windows-gnu
// x86_64-windows-none
// wasm32-wasi

// TODO:
// qemu-arm -g 1234 ./b.out
// gdb-multiarch ./b.out
// target remote localhost:1234
// tui reg general
// advance pmain

// WASMTIME_BACKTRACE_DETAILS=1 ./deb/bin/zig test ./lib/std/std.zig -target wasm32-wasi -I ./test --zig-lib-dir lib/  --test-cmd wasmtime --test-cmd --dir=. --test-cmd-bin
// Emit assembly or llvm ir
// zig build-exe -OReleaseSmall -femit-asm=min.s min.zig
// zig build-exe -OReleaseSmall -femit-llvm=min.ll min.zig
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

// SHENNANIGAN performance: array assignments work with =
test "perf array assignment" {
    const x: u8 = 100;
    const a: [1_000_000]u8 = .{x} ** 1_000_000;
    var b: [1_000_000]u8 = undefined;

    // a pile of code

    b = a; // spot the performance issue

    // a pile of code
}

// SHENNANIGAN
// Parameter Reference Optimization
// examples from @SpexGuy's talk

const BigStruct = struct {
    vals: [4]u128,
};

fn total(
    b: BigStruct, // implicit: b: *const BigStruct
) u128 {
    return b.vals[0] + b.vals[1] + b.vals[2] + b.vals[3];
}

fn totalAll(structs: []const BigStruct) u128 {
    var sum: u128 = 0;
    for (structs) |*s| {
        sum += total(s.*); // implicit: total(&(s.*));
    }
    return sum;
}

// fn debug_backtrace_stacktrace() {
// {
//     std.debug.print("putting '{s}'\n", .{dylib.id.?.name});
//     std.debug.dumpCurrentStackTrace(null);
// }

// TODO general value initialization
// const List = struct {
//     items: []T,
//     capacity: usize,
//     fn add(self: *List,
//         item: T, // implicit: item: *const T
//         ) void {
//         if (self.isFull()) {
//             self.grow();
//         }
//         self.items.len += 1;
//         slef.items[self.items.len-1] = item; // implicit: item.*
//     }
// };
// test {
//     list.add(list.items[0]); // implicit: list.add(&list.items[0]);
// }

// SHENNANIGAN
// Parameter Reference Optimization
// TODO example

// SHENNANIGAN
// RLS (Result location semantics) is implicit, but copies are eliminated
// This leads to surprising and potentially unwanted behavior.
// TODO example

// SHENNANIGAN
// Test runner allows no signaling to qemu -g 4242 (debugger mode)

// SHENNANIGAN floats
// NaN can not be conveniently tested against with standard methods and
// isNan must be used which is based on 'x != x'.

pub const SafetyLock = struct {
    pub const State = if (builtin.is_test) enum { unlocked, locked } else enum { unlocked };
    state: State = .unlocked,
    // An enum with only 1 tag is a 0-bit type just like void
    // ..
};

fn print_align() void {
    const some_num: u8 = 20;
    const some_num2: u8 = 120;
    std.debug.print("{d:4} ", .{some_num});
    std.debug.print("{d:4} ", .{some_num2});
}

const windows_utf16_string_literal = struct {
    const L = std.unicode.utf8ToUtf16LeStringLiteral;
};

// SHENNANIGAN/PERFORMANCE APIs with optional slices to multi-pointer are unflexible,
// because the pointer can not be null for the field to be unset and to be set
// in the called fn.
// This can introduce semantic problems and has a superfluos load into register
// instead of on most archs register-less 0-load.
// Example infered from Windows LookupAccountSidW which has parameter
//    Name: ?win.LPWSTR,
fn some_opt_multi_ptr_api(val: ?[*:0]u8) void {
    _ = val;
}
fn unflexible_opt_multi_ptr_api() void {
    // const acc_name: ?[*:0]u8 = undefined;
    // var raw_acc_name = @as([*:0]u8, @ptrCast(acc_name));
    // templates\common.zig:373:46: error: use of undefined value here causes undefined behavior

    // var raw_acc_name = @as([*:0]u8, @ptrCast(acc_name));
    // templates\common.zig:377:46: error: null pointer casted to type '[*:0]u8'

    var acc_name: [*:0]u8 = @as([*:0]u8, @constCast(""));
    some_opt_multi_ptr_api(acc_name[0..]);
}
test "unflexible_opt_multi_ptr_api" {
    unflexible_opt_multi_ptr_api();
}
