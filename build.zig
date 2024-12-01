const std = @import("std");
const zine = @import("zine");
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

// zig build test_all --summary all
// zig build test -Dno_opt_deps -Dno_cross --summary all
pub fn build(b: *std.Build) !void {
    const optimize: std.builtin.OptimizeMode = b.standardOptimizeOption(.{});
    // C     fmt   lint   build   proj   nounit
    // Cmake nofmt nolint nobuild noproj nounit
    // Cpp   fmt   lint   build   proj   nounit
    // Cs    nofmt nolint nobuild noproj nounit
    // Css   nofmt nolint nobuild noproj nounit
    // Fish  nofmt nolint nobuild noproj nounit
    // Java  nofmt nolint nobuild noproj nounit
    // Js    nofmt nolint nobuild noproj nounit
    // Lua   fmt   lint   nobuild noproj nounit
    // Nix   nofmt nolint nobuild noproj nounit
    // Php   nofmt nolint nobuild noproj nounit
    // Ps1   nofmt nolint nobuild noproj nounit
    // Py    nofmt nolint nobuild noproj nounit
    // Rs    nofmt nolint nobuild noproj nounit
    // Sh    fmt   lint   nobuild noproj nounit
    // Tex   nofmt nolint nobuild noproj nounit
    // Zig   fmt   lint   build   proj   unit

    // unplanned dependencies in $PATH
    // * go (shfmt)

    // optionally dependencies in $PATH
    // * cargo (stylua)
    // * haskell (shellcheck)
    // * llvm-tools (clang-format, clang-tidy)
    // * luacheck
    const no_opt_deps = b.option(bool, "no_opt_deps", "Exclude optional dependencies") orelse false; // -Dno_opt_deps
    const no_cross = b.option(bool, "no_cross", "No cross-compiling to common targets") orelse false; // -Dno_cross

    // mandatory dependencies in $PATH
    // * zig
    const run_step = b.step("test", "Test with mandatory dependencies");

    fmtC(b, run_step);
    fmtCpp(b, run_step);
    if (!no_opt_deps) fmtLua(b, run_step);
    if (!no_opt_deps) fmtSh(b, run_step);
    fmtZig(b, run_step);

    lintC(b, run_step);
    lintCpp(b, run_step);
    if (!no_opt_deps) lintLua(b, run_step);
    if (!no_opt_deps) lintSh(b, run_step);
    lintZig(b, run_step);

    { // native target
        const native_target_query: std.Target.Query = .{};
        const native_target = b.resolveTargetQuery(native_target_query);
        buildC(b, native_target, optimize, run_step);
        buildCpp(b, native_target, optimize, run_step);
        buildZig(b, native_target, optimize, run_step);
        testZig(b, native_target, optimize, run_step);
    }

    if (!no_cross) { // cross targets
        for (cross_target_queries) |cross_target_query| {
            const cross_target = b.resolveTargetQuery(cross_target_query);
            buildC(b, cross_target, optimize, run_step);
            buildCpp(b, cross_target, optimize, run_step);
            buildZig(b, cross_target, optimize, run_step);
        }
    }
}

const cross_target_queries = [_]std.Target.Query{
    .{ .cpu_arch = .aarch64, .os_tag = .linux },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .windows },
    .{ .cpu_arch = .x86_64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

fn fmtC(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleCFiles[0..]) |cfile| {
        const run_clang_format_check = b.addSystemCommand(&.{ "clang-format", "--dry-run", "--Werror" });
        run_clang_format_check.addArg(cfile);
        run_step.dependOn(&run_clang_format_check.step);
    }
}

fn lintC(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleCFiles[0..]) |cfile| {
        // clang-tidy clang-tidy_flags file -- clang_flags
        const run_clang_tidy_check = b.addSystemCommand(&.{"clang-tidy"});
        run_clang_tidy_check.addArg(cfile);
        run_clang_tidy_check.addArg("--");
        run_clang_tidy_check.addArgs(&c99_flags);
        run_step.dependOn(&run_clang_tidy_check.step);
    }
}

fn buildC(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
) void {
    var c89flags: []const []const u8 = &c89_flags;
    var c99flags: []const []const u8 = &c99_flags;
    var c11flags: []const []const u8 = &c11_flags;
    var c17flags: []const []const u8 = &c17_flags;
    var c23flags: []const []const u8 = &c23_flags;
    if (target.result.isMusl()) {
        c89flags = &(c89_flags ++ cmusl_flag);
        c99flags = &(c99_flags ++ cmusl_flag);
        c11flags = &(c11_flags ++ cmusl_flag);
        c17flags = &(c17_flags ++ cmusl_flag);
        c23flags = &(c23_flags ++ cmusl_flag);
    }
    const exe_c89 = b.addExecutable(.{
        .name = "common_c89",
        .target = target,
        .optimize = optimize,
    });
    exe_c89.addCSourceFile(.{ .file = b.path("templates/common_c89.c"), .flags = c89flags });
    exe_c89.linkLibC();
    run_step.dependOn(&exe_c89.step);

    for (SingleCFiles[0..]) |cfile| {
        const exe_cdefault = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cdefault.addCSourceFile(.{ .file = b.path(cfile) });
        exe_cdefault.linkLibC();
        run_step.dependOn(&exe_cdefault.step);

        const exe_c99 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_c99.addCSourceFile(.{ .file = b.path(cfile), .flags = c99flags });
        exe_c99.linkLibC();
        run_step.dependOn(&exe_c99.step);

        const exe_c11 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_c11.addCSourceFile(.{ .file = b.path(cfile), .flags = c11flags });
        exe_c11.linkLibC();
        run_step.dependOn(&exe_c11.step);

        const exe_c17 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_c17.addCSourceFile(.{ .file = b.path(cfile), .flags = c17flags });
        exe_c17.linkLibC();
        run_step.dependOn(&exe_c17.step);

        const exe_c23 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_c23.addCSourceFile(.{ .file = b.path(cfile), .flags = c23flags });
        exe_c23.linkLibC();
        run_step.dependOn(&exe_c23.step);
    }
}

// fn checkCmake() void {} // nofmt nolint nobuild noproj

fn fmtCpp(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleCppFiles[0..]) |cfile| {
        const run_clang_format_check = b.addSystemCommand(&.{ "clang-format", "--dry-run", "--Werror" });
        run_clang_format_check.addArg(cfile);
        run_step.dependOn(&run_clang_format_check.step);
    }
}

fn lintCpp(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleCppFiles[0..]) |cfile| {
        // clang-tidy clang-tidy_flags file -- clang_flags
        const run_clang_tidy_check = b.addSystemCommand(&.{"clang-tidy"});
        run_clang_tidy_check.addArg(cfile);
        run_clang_tidy_check.addArg("--");
        run_clang_tidy_check.addArgs(&cpp14_flags);
        run_step.dependOn(&run_clang_tidy_check.step);
    }
}

fn buildCpp(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
) void {
    var cpp14flags: []const []const u8 = &cpp14_flags;
    var cpp17flags: []const []const u8 = &cpp17_flags;
    var cpp20flags: []const []const u8 = &cpp20_flags;
    var cpp23flags: []const []const u8 = &cpp23_flags;
    var cpp26flags: []const []const u8 = &cpp26_flags;
    if (target.result.isMusl()) {
        cpp14flags = &(cpp14_flags ++ cppmusl_flag);
        cpp17flags = &(cpp17_flags ++ cppmusl_flag);
        cpp20flags = &(cpp20_flags ++ cppmusl_flag);
        cpp23flags = &(cpp23_flags ++ cppmusl_flag);
        cpp26flags = &(cpp26_flags ++ cppmusl_flag);
    }
    for (SingleCppFiles[0..]) |cppfile| {
        const exe_cppdefault = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cppdefault.addCSourceFile(.{ .file = b.path(cppfile) });
        exe_cppdefault.linkLibCpp();
        run_step.dependOn(&exe_cppdefault.step);

        const exe_cpp14 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cpp14.addCSourceFile(.{ .file = b.path(cppfile), .flags = cpp14flags });
        exe_cpp14.linkLibCpp();
        run_step.dependOn(&exe_cpp14.step);

        const exe_cpp17 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cpp17.addCSourceFile(.{ .file = b.path(cppfile), .flags = cpp17flags });
        exe_cpp17.linkLibCpp();
        run_step.dependOn(&exe_cpp17.step);

        const exe_cpp20 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cpp20.addCSourceFile(.{ .file = b.path(cppfile), .flags = cpp20flags });
        exe_cpp20.linkLibCpp();
        run_step.dependOn(&exe_cpp20.step);

        const exe_cpp23 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cpp23.addCSourceFile(.{ .file = b.path(cppfile), .flags = cpp23flags });
        exe_cpp23.linkLibCpp();
        run_step.dependOn(&exe_cpp23.step);

        const exe_cpp26 = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cpp26.addCSourceFile(.{ .file = b.path(cppfile), .flags = cpp26flags });
        exe_cpp26.linkLibCpp();
        run_step.dependOn(&exe_cpp26.step);
    }
}

// fn checkCs() void {} // nofmt nolint nobuild noproj
// fn checkCss() void {} // nofmt nolint nobuild noproj
// fn checkFish() void {} // nofmt nolint nobuild noproj
// fn checkJava() void {} // nofmt nolint nobuild noproj
// fn checkJs() void {} // nofmt nolint nobuild noproj

fn fmtLua(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleLuaFiles[0..]) |luafile| {
        const run_stylua_check = b.addSystemCommand(&.{ "stylua", "--check" });
        run_stylua_check.addArg(luafile);
        run_step.dependOn(&run_stylua_check.step);
    }
}

fn lintLua(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleLuaFiles[0..]) |luafile| {
        const run_luacheck = b.addSystemCommand(&.{ "luacheck", "--no-color", "-q" });
        run_luacheck.addArg(luafile);
        const expected_msg =
            \\Total: 0 warnings / 0 errors in 1 file
            \\
        ;
        run_luacheck.expectStdOutEqual(expected_msg);
        run_step.dependOn(&run_luacheck.step);
    }
}

// fn checkNix() void {} // nofmt nolint nobuild noproj
// fn checkPhp() void {} // nofmt nolint nobuild noproj
// fn checkPs1() void {} // nofmt nolint nobuild noproj
// fn checkPy() void {} // nofmt nolint nobuild noproj
// fn checkRs() void {} // nofmt nolint nobuild noproj

fn fmtSh(b: *std.Build, run_step: *std.Build.Step) void {
    // shfmt has no way to disable fmt / check mode, so it is not enabled
    _ = b;
    _ = run_step;
    // for (SingleShFiles[0..]) |shfile| {
    //         const run_shfmt_check = b.addSystemCommand(&.{"shfmt"});
    //         run_shfmt_check.addArg(shfile);
    //         run_step.dependOn(&run_shfmt_check.step);
    // }
}

fn lintSh(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleShFiles[0..]) |shfile| {
        const run_shellcheck = b.addSystemCommand(&.{"shellcheck"});
        run_shellcheck.addArg(shfile);
        run_step.dependOn(&run_shellcheck.step);
    }
}

// fn checkTex() void {} // nofmt nolint nobuild noproj

fn fmtZig(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleZigFiles[0..]) |zigfile| {
        const run_shellcheck = b.addSystemCommand(&.{ "zig", "fmt", "--check" });
        run_shellcheck.addArg(zigfile);
        run_step.dependOn(&run_shellcheck.step);
    }
}

fn lintZig(b: *std.Build, run_step: *std.Build.Step) void {
    for (SingleZigFiles[0..]) |zigfile| {
        const run_shellcheck = b.addSystemCommand(&.{ "zig", "ast-check" });
        run_shellcheck.addArg(zigfile);
        run_step.dependOn(&run_shellcheck.step);
    }
}

fn buildZig(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
) void {
    for (SingleZigFiles[0..]) |zigfile| {
        const exe_zigfile = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(zigfile)),
            .root_source_file = b.path(zigfile),
            .target = target,
            .optimize = optimize,
        });
        run_step.dependOn(&exe_zigfile.step);
    }
}

fn testZig(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
) void {
    for (SingleZigFiles[0..]) |zigfile| {
        const zigfile_unit_tests = b.addTest(.{
            .root_source_file = b.path(zigfile),
            .target = target,
            .optimize = optimize,
        });
        const run_zigfile_unit_tests = b.addRunArtifact(zigfile_unit_tests);
        run_step.dependOn(&run_zigfile_unit_tests.step);
    }
}

// zig cc flags
const cmusl_flag = [_][]const u8{"-Wno-disabled-macro-expansion"};
const c89_flags = [_][]const u8{ "-std=c89", "-Werror", "-Weverything" };
const c99_flags = [_][]const u8{ "-std=c99", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default" };
const c11_flags = [_][]const u8{ "-std=c11", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-pre-c11-compat" };
const c17_flags = [_][]const u8{ "-std=c17", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-pre-c11-compat" };
const c23_flags = [_][]const u8{ "-std=c23", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-c++98-compat", "-Wno-pre-c11-compat", "-Wno-pre-c23-compat" };

const SingleCFiles = [_][]const u8{
    // "example/gdb/adv/catch.c",
    // "example/gdb/adv/dll_injection_unix.c",
    // "example/gdb/adv/dll_injection_win.c",
    // "example/gdb/adv/fn_instrumentation.c",
    // "example/gdb/adv/fn_runtime_patching.c",
    // "example/gdb/adv/ld_preload.c",
    // "example/gdb/adv/ld_preload_replacements.c", // gdb project
    "example/gdb/inf_loop.c",
    // "example/link/main.c",
    // "example/link/memcpy.c", // custom link example
    // "example/memcpy_avx.c", // unsafe pointer arithmetic
    "example/opaque.c",
    // "example/openssl_aes.c", // requires -Wpadded to workaround upstream openssl
    "example/operator_precedence.c",
    "example/portable_printf.c",
    // "example/provenance_miscompilation/extern.c",
    // "example/provenance_miscompilation/ptr_provenance_miscompilation.c",
    "example/sequence_points.c",
    "example/util_string.c",
    "example/why_clang_tidy.c",
    "templates/colors.c",
    "templates/common.c",
    // "templates/common_c89.c", // separately tested
    // "templates/flags.c", // no usable code
    "templates/hacks.c",
    "templates/server.c",
};

// zig c++ flags
const cppmusl_flag = [_][]const u8{"-Wno-disabled-macro-expansion"};
const cpp14_flags = [_][]const u8{ "-std=c++14", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const cpp17_flags = [_][]const u8{ "-std=c++17", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const cpp20_flags = [_][]const u8{ "-std=c++20", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const cpp23_flags = [_][]const u8{ "-std=c++23", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const cpp26_flags = [_][]const u8{ "-std=c++26", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };

const SingleCppFiles = [_][]const u8{
    "example/common.cpp",
    // "example/cpp23_modules/main_clang.cpp", C++23
    // "example/cpp23_modules/main_msvc.cpp", C++23
    // "example/implicit_string_conversion.cpp", // additional flags show problem
    "example/minimal_cpp.cpp",
    "example/msvc.cpp",
    "example/utf8/stringable.cpp",
    // "example/utf8/tests.cpp", C++20
    "templates/common.cpp",
    // "templates/flags.cpp", flag collection, no code
    "templates/hacks.cpp",
};

const SingleLuaFiles = [_][]const u8{
    ".config/nvim/init.lua",
    ".config/nvim/lua/dap/my_dap.lua",
    ".config/nvim/lua/dap/my_dap_pickers.lua",
    ".config/nvim/lua/my_aerial.lua",
    ".config/nvim/lua/my_buf.lua",
    ".config/nvim/lua/my_cmds.lua",
    ".config/nvim/lua/my_dap.lua",
    ".config/nvim/lua/my_fmt.lua",
    ".config/nvim/lua/my_gdb.lua",
    ".config/nvim/lua/my_gitsign.lua",
    ".config/nvim/lua/my_harpoon.lua",
    ".config/nvim/lua/my_hydra.lua",
    ".config/nvim/lua/my_jfind.lua",
    ".config/nvim/lua/my_keymaps.lua",
    ".config/nvim/lua/my_lint.lua",
    ".config/nvim/lua/my_lsp.lua",
    ".config/nvim/lua/my_nvimcmp.lua",
    ".config/nvim/lua/my_oil.lua",
    ".config/nvim/lua/my_opts.lua",
    ".config/nvim/lua/my_over.lua",
    ".config/nvim/lua/my_packer.lua",
    ".config/nvim/lua/my_plugins.lua",
    ".config/nvim/lua/my_rust.lua",
    ".config/nvim/lua/my_statusline.lua",
    ".config/nvim/lua/my_surround.lua",
    ".config/nvim/lua/my_telesc.lua",
    ".config/nvim/lua/my_treesitter.lua",
    ".config/nvim/lua/my_utils.lua",
    ".config/nvim/lua/overseer/component/validate.lua",
    ".config/nvim/lua/overseer/template/user/cpp_build.lua",
    ".config/nvim/lua/overseer/template/user/run_script.lua",
    "templates/callback.lua",
    "templates/common.lua",
    "templates/min_gitsigns.lua",
    "templates/min_init.lua",
    "templates/nvim.lua",
    "templates/profile.lua",
    "windows/.config/wezterm/wezterm.lua",
};

const SingleShFiles = [_][]const u8{
    "checkHealth.sh",
    "crosscompiling/entr.sh",
    "crosscompiling/watchFileTouchRm.sh",
    "crosscompiling/zcc.sh",
    "crosscompiling/zcpp.sh",
    // "example/bracketsChecking.sh", // shell piping is cursed
    "example/link/link1.sh",
    "example/provenance_miscompilation/cerberus_install.sh",
    "fileBackup.sh",
    "fileRemove.sh",
    "fileRestore.sh",
    "mustcopy/cpfiles.sh",
    "scr/bWSLZigWinDevKit.sh",
    "scr/bare_git/exec_from_other_worktree.sh",
    "scr/bare_git/getFiles.sh",
    "scr/bare_git/min_ctags.sh",
    "scr/bare_git/prepareBuild.sh",
    "scr/bare_git/setupWorktree.sh",
    "scr/basic_ctags.sh",
    "scr/bisect.sh",
    "scr/checkup_git.sh",
    "scr/ctags.sh",
    "scr/deploy.sh",
    "scr/fZigWinDevKit.sh",
    "scr/gen_ssh.sh",
    "scr/installNixFlakes.sh",
    "scr/installOverlays.sh",
    "scr/merge_compilercommands.sh",
    "scr/mkVid.sh",
    "scr/restart_pulseaudio.sh",
    "scr/scan.sh",
    "scr/setupOverlays.sh",
    "scr/uninstallNixMultiUser.sh",
    "scr/unlock_screen.sh",
    "scr/updateOverlays.sh",
    "symlinkInstall.sh",
    "symlinkUninstall.sh",
    "templates/common.sh",
    "templates/crosscompiling_zig.sh",
    "templates/gdbinit.sh",
    "templates/update_nix_nixos.sh",
};

const SingleZigFiles = [_][]const u8{
    // "build.zig", // build file
    // "example/copyhound.zig", // missing dep
    "example/sudo/sudo_shell.zig",
    // "example/zigpkg/build.zig",
    // "example/zigpkg/src/main.zig",
    // "example/zigpkg/src/root.zig", // zigpkg project
    "scr/sh.zig",
    "templates/common.zig",
    "templates/hacks.zig",
};
