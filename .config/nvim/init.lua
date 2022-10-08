-- init.lua --
require 'my_globals'
local has_packer, _ = pcall(require, 'packer')
if has_packer then
  require 'my_packer'
else
  error 'Please install packer, instructions in my_packer.lua'
end
require 'my_opts'
-- require 'my_lsp' -- setup in my_nvimcmp.lua
require 'my_telesc'
require 'my_nvimcmp'
--require('my_treesitter') -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
--require('my_dap') -- idea setup one small step for vimkind
require 'my_keymaps'
require 'my_cmds'
require 'my_gitsign'
require 'my_hydra'
vim.cmd [[colorscheme material]]

-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
_G.Clangfmt = function()
  -- bufmodified include only modified buffers.
  -- looking upwards paths for a .clang-format, ideal solution would try to use root git folder
  -- => use  getbufinfo([{buf}]), bufname() ?
  -- if dict.name == vim.fn.bufname(%:blubb) then
  -- cna formatters provide us with more information for smarter cursor positioning???
  vim.api.nvim_command [[
if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
  let cursor_pos = getpos('.')
  :%!clang-format
  call setpos('.', cursor_pos)
end
]]
end

-- https://alpha2phi.medium.com/learn-neovim-the-practical-way-8818fcf4830f
-- TODO: simple task runner
-- TODO: simple diff that respects gitignore
-- TODO: build + test + spawn suite for debugging
-- idea: investigate use cases of ropes and implement one for Zig <-- defered
-- until stage2 allows users to get Sema info
-- TODO: idea for analysis IR: "RVSDG: An Intermediate Representation for Optimizing Compilers"
-- TODO: complete deltadebug/zig-reduce to get complete AST<->source locations

-- working with macros
-- https://stackoverflow.com/questions/2024443/saving-vim-macros
-- macros are stored in the regular registers and can be pasted or executed
-- explicit writing of macro content: let @a='0fa'
-- NOTE: use C-r C-r to insert contents of the a register to prevent execution on pasting!
-- Appending macros of register a with qA..q

-- working with regex
-- :help non-greedy
-- Instead of .* use .\{-}, for example %s/style=".\{-}"//g to remove occurences of style="..."
-- https://stackoverflow.com/questions/1305853/how-can-i-make-my-match-non-greedy-in-vim
-- another option for multiple matches is :%s/\v(style|class)\=".{-}"//g
-- To match escaped string symbols of JSON use /\\".\{-}\\"
-- and not /\\".*\\"

-- stylua: ignore start
-- extend highlighting time, remove trailing spaces except in markdown files, call Clangfmt
vim.api.nvim_create_augroup('MYAUCMDS',  {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {group = 'MYAUCMDS', pattern = '*', callback = function() require'vim.highlight'.on_yank({timeout = 100}) end})
--vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = '*', command = [[:keepjumps keeppatterns %s/\s\+$//e]]}) -- remove trailing spaces
vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = { '*.h', '*.hpp', '*.c', '*.cpp' }, command = [[:lua Clangfmt()]]})
vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = '*',
callback = function()
    if vim.bo.filetype == "markdown" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\v\s+$//e]]) -- remove trailing spaces
    vim.fn.winrestview(view)
    --vim.api.nvim_command [[:keepjumps keeppatterns %s/\s\+$//e]] -- remove trailing spaces
  end,
})
-- stylua: ignore end

-- keywords (capitalized): hack,todo,fixme

-- type() and inspect()
-- idea Repltikzbuild: compare mtimes
-- check hash implementations in lua5.1 for incremental builds
-- xxhash has luajit implementation -> not needed, only mtime comparison

--makeglossaries main.

-- Snippets
-- c++
--std::cout << "type: " << typeid(eout).name() << "\n";
-- lua
--print (filename)
-- vimscript
--:echo '123'

-- :h builtin-function-list
-- :h lua-fs (os.path python functions)

-- Debugging Lua types and values
-- print(type(fd_exec[1]))
-- :g/.*DEBUG$/del
-- local fp = assert(io.open("/tmp/tmpfile", "w")) --DEBUG
-- for index,tables in pairs(repo_paths) do        --DEBUG
--   fp:write(index)                               --DEBUG
--   fp:write(", ")                                --DEBUG
--   fp:write(tables)                              --DEBUG
--   fp:write("\n")                                --DEBUG
-- end                                             --DEBUG
-- fp:close()                                      --DEBUG

-- local fp = assert(io.open("/tmp/tmpfile", "w")) --DEBUG
-- for index,tables in ipairs(repo_paths) do       --DEBUG
--   fp:write(index)                               --DEBUG
--   fp:write(", ")                                --DEBUG
--   fp:write(tostring(tables))                    --DEBUG
--   fp:write("\n")                                --DEBUG
-- end                                             --DEBUG
-- fp:close()                                      --DEBUG
--
-- Debugging Python types
-- print(type(tokenInfo_json))
-- print(tokenInfo_obj.__dict__)
--
-- Debugging Zig types
-- @compileLog(@TypeOf(input));
--
-- Debugging C++ values
-- std::cout << ": " <<  << "\n";    // DEBUG
-- std::cout << ": " <<  << "\n";    // DEBUG
-- touch /tmp/debug.log
-- std::ofstream ofstr("/tmp/debug.log", std::ios_base::app); // assume the file already exists
-- ofstr << "msCompositeSchedule._sChargingRateUnit_tempString: " << msCompositeSchedule._sChargingRateUnit_tempString << "\n";
-- ofstr.close();
--#include <iostream>
--#include <fstream>
--#include <string>
--// Usage example: filePutContents("./yourfile.txt", "content", true);
--void filePutContents(const std::string& name, const std::string& content, bool append = false) {
--    std::ofstream outfile;
--    if (append)
--        outfile.open(name, std::ios_base::app);
--    else
--        outfile.open(name);
--    outfile << content;
--}
--
-- convert windows line ending to linux:
-- :%s/^M$//
-- convert tabs to spaces:
-- :retab
-- convert command with space to newline with \
-- / / \\\r/g
-- convert back cmd separated by \ to space separated commands
-- /\\\n/ /
-- convert symbols into hex: !%xxd

-- std::cout << "dbg1\n"; // DEBUG
-- search with /.*DEBUG$
-- delete with :g/.*DEBUG$/del

-- ./runTests --gtest_filter='minimalz3.*'
-- gdb --ex run --args ./test_pde --gtest_filter='Nestout.*' --gtest_break_on_failure
-- set follow-fork-mode mode

-- Fast init
-- pub fn main() !void {}
-- var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
-- defer std.debug.assert(!general_purpose_allocator.deinit());
-- const gpa = general_purpose_allocator.allocator();

-- var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
-- defer arena_instance.deinit();
-- const arena = arena_instance.allocator();

-- var cwd_buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
-- std.mem.copy(u8, filepathbuf[0..], pathprefix[0..]);
-- const pathprefnr = try std.fmt.bufPrint(filepathbuf[pathprefix.len..], "{d}", .{i});

-- Fast printErrorSet
--fn printErrorSet(comptime fun: anytype) void {
--    const info = @typeInfo(@TypeOf(fun));
--    const ret_type = info.Fn.return_type.?;
--    inline for (@typeInfo(@typeInfo(ret_type).ErrorUnion.error_set).ErrorSet.?) |reterror| {
--        std.debug.print("{s}\n", .{reterror.name});
--    }
--}
--test "printErrorSet" {
--    printErrorSet(resolvePosix);
--}

-- Assume
--PWD=$(git rev-parse --show-toplevel) == pwd.
-- Create Makefiles
--
-- Run Makefile for unit test
--
-- Run unit test
--
