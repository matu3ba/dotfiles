const std = @import("std");
const zine = @import("zine");
const ResolvedTarget = std.Build.ResolvedTarget;
const OptimizeMode = std.builtin.OptimizeMode;

// zig build test_all --summary all
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    //checkC     fmt   lint   build   proj   nounit
    //checkCmake nofmt nolint nobuild noproj nounit
    //checkCpp   fmt   lint   build   proj   nounit
    //checkCs    nofmt nolint nobuild noproj nounit
    //checkCss   nofmt nolint nobuild noproj nounit
    //checkFish  nofmt nolint nobuild noproj nounit
    //checkJava  nofmt nolint nobuild noproj nounit
    //checkJs    nofmt nolint nobuild noproj nounit
    //checkLua   fmt   lint   nobuild noproj nounit
    //checkNix   nofmt nolint nobuild noproj nounit
    //checkPhp   nofmt nolint nobuild noproj nounit
    //checkPs1   nofmt nolint nobuild noproj nounit
    //checkPy    nofmt nolint nobuild noproj nounit
    //checkRs    nofmt nolint nobuild noproj nounit
    //checkSh    fmt   lint   nobuild noproj nounit
    //checkTex   nofmt nolint nobuild noproj nounit
    //checkZig   fmt   lint   build   proj   unit

    // unplanned dependencies in $PATH
    // * go (shfmt)

    // optionally dependencies in $PATH
    // * cargo (stylua)
    // * haskell (shellcheck)
    // * llvm-tools (clang-format, clang-tidy)
    // * luacheck
    // -Dno_opt_deps
    const no_opt_deps = b.option(bool, "no_opt_deps", "Exclude optional dependencies") orelse false;

    // mandatory dependencies in $PATH
    // * zig
    const run_step = b.step("test", "Test with mandatory dependencies");

    checkC(b, target, optimize, run_step, no_opt_deps);
    checkCpp(b, target, optimize, run_step, no_opt_deps);
    checkLua(b, run_step, no_opt_deps);
    checkSh(b, run_step, no_opt_deps);
    checkZig(b, target, optimize, run_step);
}

fn checkC(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
    no_opt_deps: bool,
) void {
    // fmt lint build
    for (SingleCFiles[0..]) |cfile| {
        if (!no_opt_deps) {
            const run_clang_format_check = b.addSystemCommand(&.{ "clang-format", "--dry-run", "--Werror" });
            run_clang_format_check.addArg(cfile);
            run_step.dependOn(&run_clang_format_check.step);

            // const run_clang_tidy_check = b.addSystemCommand(&.{"clang-tidy"});
            // run_clang_tidy_check.addArg(cfile);
            // TODO adjust clang flags -- -I include_path -D MY_DEFINES ...
            // run_step.dependOn(&run_clang_tidy_check.step);
        }

        const run_zig_cc_c99 = b.addSystemCommand(zig_cc_c99_cmd);
        run_zig_cc_c99.addArg(cfile);
        run_step.dependOn(&run_zig_cc_c99.step);

        const run_zig_cc_c11 = b.addSystemCommand(zig_cc_c11_cmd);
        run_zig_cc_c11.addArg(cfile);
        run_step.dependOn(&run_zig_cc_c11.step);

        const run_zig_cc_c17 = b.addSystemCommand(zig_cc_c17_cmd);
        run_zig_cc_c17.addArg(cfile);
        run_step.dependOn(&run_zig_cc_c17.step);

        const run_zig_cc_c23 = b.addSystemCommand(zig_cc_c23_cmd);
        run_zig_cc_c23.addArg(cfile);
        run_step.dependOn(&run_zig_cc_c23.step);

        const exe_cfile = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cfile.addCSourceFile(.{ .file = b.path(cfile) });
        exe_cfile.linkLibC();
        run_step.dependOn(&exe_cfile.step);
    }

    // special c89 file
    const run_zig_cc_c89 = b.addSystemCommand(zig_cc_c89_cmd);
    run_zig_cc_c89.addArg("templates/common_c89.c");
    run_step.dependOn(&run_zig_cc_c89.step);

    // proj TODO
}

fn checkCmake() void {} // nofmt nolint nobuild noproj

fn checkCpp(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
    run_step: *std.Build.Step,
    no_opt_deps: bool,
) void {
    // fmt lint build
    for (SingleCppFiles[0..]) |cppfile| {
        if (!no_opt_deps) {
            const run_clang_format_check = b.addSystemCommand(&.{ "clang-format", "--dry-run", "--Werror" });
            run_clang_format_check.addArg(cppfile);
            run_step.dependOn(&run_clang_format_check.step);

            // const run_clang_tidy_check = b.addSystemCommand(&.{"clang-tidy"});
            // run_clang_tidy_check.addArg(cppfile);
            // TODO adjust clang flags -- -I include_path -D MY_DEFINES ...
            // run_step.dependOn(&run_clang_tidy_check.step);
        }

        const run_zig_cpp_c14 = b.addSystemCommand(zig_cpp_c14_cmd);
        run_zig_cpp_c14.addArg(cppfile);
        run_step.dependOn(&run_zig_cpp_c14.step);

        const run_zig_cpp_c17 = b.addSystemCommand(zig_cpp_c17_cmd);
        run_zig_cpp_c17.addArg(cppfile);
        run_step.dependOn(&run_zig_cpp_c17.step);

        const run_zig_cpp_c20 = b.addSystemCommand(zig_cpp_c20_cmd);
        run_zig_cpp_c20.addArg(cppfile);
        run_step.dependOn(&run_zig_cpp_c20.step);

        const run_zig_cpp_c23 = b.addSystemCommand(zig_cpp_c23_cmd);
        run_zig_cpp_c23.addArg(cppfile);
        run_step.dependOn(&run_zig_cpp_c23.step);

        const run_zig_cpp_c26 = b.addSystemCommand(zig_cpp_c26_cmd);
        run_zig_cpp_c26.addArg(cppfile);
        run_step.dependOn(&run_zig_cpp_c26.step);

        const exe_cfile = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(cppfile)),
            .target = target,
            .optimize = optimize,
        });
        exe_cfile.addCSourceFile(.{ .file = b.path(cppfile) });
        exe_cfile.linkLibCpp();
        run_step.dependOn(&exe_cfile.step);
    }
}
fn checkCs() void {} // nofmt nolint nobuild noproj
fn checkCss() void {} // nofmt nolint nobuild noproj
fn checkFish() void {} // nofmt nolint nobuild noproj
fn checkJava() void {} // nofmt nolint nobuild noproj
fn checkJs() void {} // nofmt nolint nobuild noproj

fn checkLua(b: *std.Build, run_step: *std.Build.Step, no_opt_deps: bool) void {
    // fmt lint nobuild noproj
    for (SingleLuaFiles[0..]) |luafile| {
        if (!no_opt_deps) {
            const run_stylua_check = b.addSystemCommand(&.{ "stylua", "--check" });
            run_stylua_check.addArg(luafile);
            run_step.dependOn(&run_stylua_check.step);

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
}

fn checkNix() void {} // nofmt nolint nobuild noproj
fn checkPhp() void {} // nofmt nolint nobuild noproj
fn checkPs1() void {} // nofmt nolint nobuild noproj
fn checkPy() void {} // nofmt nolint nobuild noproj
fn checkRs() void {} // nofmt nolint nobuild noproj

fn checkSh(b: *std.Build, run_step: *std.Build.Step, no_opt_deps: bool) void {
    // fmt lint nobuild noproj
    for (SingleShFiles[0..]) |shfile| {
        if (!no_opt_deps) {
            // shfmt has no way to disable fmt and check mode, so it is not included
            // const run_shfmt_check = b.addSystemCommand(&.{"shfmt"});
            // run_shfmt_check.addArg(shfile);
            // run_step.dependOn(&run_shfmt_check.step);

            const run_shellcheck = b.addSystemCommand(&.{"shellcheck"});
            run_shellcheck.addArg(shfile);
            run_step.dependOn(&run_shellcheck.step);
        }
    }
}

fn checkTex() void {} // nofmt nolint nobuild noproj

fn checkZig(b: *std.Build, target: ResolvedTarget, optimize: OptimizeMode, run_step: *std.Build.Step) void {
    // fmt lint build
    for (SingleZigFiles[0..]) |zigfile| {
        // fmt check run by CI in .github/workflows/ci.yml: zig fmt --check .

        const run_shellcheck = b.addSystemCommand(&.{ "zig", "ast-check" });
        run_shellcheck.addArg(zigfile);
        run_step.dependOn(&run_shellcheck.step);

        const zigfile_unit_tests = b.addTest(.{
            .root_source_file = b.path(zigfile),
            .target = target,
            .optimize = optimize,
        });
        const run_zigfile_unit_tests = b.addRunArtifact(zigfile_unit_tests);
        run_step.dependOn(&run_zigfile_unit_tests.step);

        const exe_zigfile = b.addExecutable(.{
            .name = std.fs.path.stem(std.fs.path.basename(zigfile)),
            .root_source_file = b.path(zigfile),
            .target = target,
            .optimize = optimize,
        });
        run_step.dependOn(&exe_zigfile.step);
    }

    // proj TODO
}

const zig_cc_c89_cmd = &.{ "zig", "cc", "-std=c89", "-Werror", "-Weverything" };
const zig_cc_c99_cmd = &.{ "zig", "cc", "-std=c99", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default" };
const zig_cc_c11_cmd = &.{ "zig", "cc", "-std=c11", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-pre-c11-compat" };
const zig_cc_c17_cmd = &.{ "zig", "cc", "-std=c17", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-pre-c11-compat" };
const zig_cc_c23_cmd = &.{ "zig", "cc", "-std=c23", "-Werror", "-Weverything", "-Wno-unsafe-buffer-usage", "-Wno-declaration-after-statement", "-Wno-switch-default", "-Wno-c++98-compat", "-Wno-pre-c11-compat", "-Wno-pre-c23-compat" };

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
    "example/why_clang_tidy.c",
    "templates/colors.c",
    "templates/common.c",
    // "templates/common_c89.c", // separately tested
    // "templates/flags.c", // no usable code
    "templates/hacks.c",
    "templates/server.c",
};

const zig_cpp_c14_cmd = &.{ "zig", "c++", "-std=c++14", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const zig_cpp_c17_cmd = &.{ "zig", "c++", "-std=c++17", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const zig_cpp_c20_cmd = &.{ "zig", "c++", "-std=c++20", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const zig_cpp_c23_cmd = &.{ "zig", "c++", "-std=c++23", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };
const zig_cpp_c26_cmd = &.{ "zig", "c++", "-std=c++26", "-Werror", "-Weverything", "-Wno-c++98-compat-pedantic", "-Wno-c++20-compat", "-Wno-unsafe-buffer-usage", "-Wno-switch-default" };

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
