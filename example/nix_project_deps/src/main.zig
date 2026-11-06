const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const gpa = init.gpa;
    _ = init.environ_map;
    {
        var args = try init.minimal.args.iterateAllocator(gpa);
        defer args.deinit();
        _ = args.skip(); // process name
        while (args.next()) |arg| {
            _ = arg;
        }
    }
    printHelp(io);
}

fn printHelp(io: std.Io) void {
    var buf: [1024]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const stdout = &w.interface;
    stdout.writeAll(
        \\appname - app description
        \\
        \\Usage: appname [options]
        \\  -arg, --longarg <number> Some explanation what arg does
        \\  -d, --dry                Only print what would be executed.
        \\  -h, --help               Show this help.
        \\
        \\Usage instructions, if needed.
        \\
    ) catch return;
    stdout.flush() catch {};
}
