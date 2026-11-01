const std = @import("std");

// files with unit tests
pub const ini = @import("ini.zig");

test {
    _ = @import("ini.zig");
    // std.testing.refAllDecls(@This());

    // alternativeto refAllDecls is to use some duplication in the root module
    // _ = ini;
    // xor _ = @import("ini.zig");
}
