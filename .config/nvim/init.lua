--! Main entry point, very common things and autocommands
-- luacheck: globals vim
require 'my_opts'
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/.local/share/nvim/lazy/lazy.nvim
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/AppData/Local/nvim-data/lazy/lazy.nvim
-- cp -r $HOME/dotfiles/.config/nvim $HOME/AppData/Local/nvim
-- treesitter languages may require: cargo install tree-sitter-cli
-- :lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))
-- vim.opt.runtimepath:get(), :h vim.opt
-- vim.opt.rtp:append()
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local has_lazy = vim.loop.fs_stat(lazypath)
if not has_lazy then
  print 'Please install lazy, instructions in init.lua'
else
  vim.opt.runtimepath:prepend(lazypath)
  require('lazy').setup('my_plugins', {})
  -- TODO add missing pcalls/checks in treesitter and telescope-fzf-native
  -- TODO handle file got deleted without statusline becoming broken

  -- TODO create minimal bare repo for diffview.nvim problem DiffviewFileHistory not working:
  -- https://github.com/sindrets/diffview.nvim
  -- TODO create minimal example to ask why gitsignas is very slow and how to expand folds to see
  -- all diff hunks https://github.com/lewis6991/gitsigns.nvim

  require 'my_dap'  -- :lua= require("dap").session().capabilities.supportsCompletionsRequest
  require 'my_treesitter' -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
  require 'my_telesc'
  require 'my_gitsign'
  require 'my_hydra'
  require 'my_lsp' -- setup in my_nvimcmp.lua
  require 'my_lint' -- setup in my_lint.lua
  require 'my_statusline'
  -- workaronud lazy caching init.lua loading, but the module might be absent.
  local has_libbuf, _ = pcall(require, 'libbuf')
  if has_libbuf then require 'my_buf' end
  vim.cmd [[colorscheme material]]
end

require 'my_cmds'
require 'my_keymaps'
--require 'my_nvimcmp'

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

-- GOOD_TO_KNOW
-- * debugger scheduling control with gdb
-- * write some functions for custom debugging print
-- * (assembly) inspection techniques
-- * tracing + resolving broken logic

-- zellij keybindings:
-- A-[1-8] for panes
-- A-a left tab, A-f right tab

-- https://alpha2phi.medium.com/learn-neovim-the-practical-way-8818fcf4830f
-- idea: simple diff that respects gitignore https://github.com/ziglibs/diffz

-- TODO (advanced) linker workshop to understand linker
-- TODO: play around with build + test + spawn suite for debugging vs simulation
-- * use case: debugging mocking linker failures in C++

-- TODO: reduze with getting AST<->source locations
-- idea: https://jdhao.github.io/2020/11/15/nvim_text_objects/
--       and https://github.com/nvim-treesitter/nvim-treesitter-textobjects
-- LLVM Optimization IR: "RVSDG: An Intermediate Representation for Optimizing Compilers"
-- better C semantics: "RefinedC: Automating the Foundational Verification of
--                      C Code with Refined Ownership Types"

-- working with macros
-- https://stackoverflow.com/questions/2024443/saving-vim-macros
-- macros are stored in the regular registers and can be pasted or executed
-- explicit writing of macro content: let @a='0fa'
-- NOTE: use C-r C-r to insert contents of the a register to prevent execution on pasting!
-- Appending macros of register a with qA..q
-- @@ replays last macro
-- @: replays last command

-- working with regex
-- :help non-greedy
-- Instead of .* use .\{-}, for example %s/style=".\{-}"//g to remove occurences of style="..."
-- https://stackoverflow.com/questions/1305853/how-can-i-make-my-match-non-greedy-in-vim
-- another option for multiple matches is :%s/\v(style|class)\=".{-}"//g
-- To match escaped string symbols of JSON use /\\".\{-}\\"
-- and not /\\".*\\"
-- literal substitution requires very non magic mode https://stackoverflow.com/a/46235399
-- replacement with argument:
-- %s/\(.\)word/replacement \1
-- TODO: selection + substitute selection with (simplify)

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

-- type(), inspect(), :Inspect, vim.show_pos(), vim.inspect_pos()
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
-- Shell
-- printf '\7'
-- printf '\a'
-- echo -ne '\7'

-- :h builtin-function-list
-- :h lua-fs (os.path python functions)

-- Debugging Lua types + values, see also ./lua/my_utils.lua dump, printPairsToTmp, printIpairsToTmp
-- unpack to unpack a table
-- `:lua = vim.fs`, `:lua = x` (short forms of `:lua vim.pretty_print(vim.fs)`)
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
-- Execute something and add it to current buffer.
-- :put = execute('messages')
-- Debugging Environment variables
-- :redir @a
-- :fancy command
-- :redir END
-- visual mode: "ap

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

-- C-r C-o/C-r C-r register: paste text literally
-- C-r register: pasting from register

-- verbatim replace (snomagic)
-- :sno/search/replace/g
-- remove trailing carriage returns (^M), ie of windows
--:e ++ff=dos
--:set ff=unix
--C-vC-m inserts ^M
-- convert windows line ending to linux:
-- :%s/^M$//
-- somehow this also works
-- :%s/\r//g
-- convert tabs to spaces:
-- :retab
-- convert command with space to newline with \
-- / / \\\r/g
-- convert back cmd separated by \ to space separated commands
-- /\\\n/ /
-- convert symbols into hex: !%xxd
-- show non-text ascii symbols with :ascii

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

-- Removing Zig cache (for nested in project build.zig file)
--ZIGCACHE=$(fd -uu zig-cache) && rm -fr $ZIGCACHE && fd -uu zig-cache

-- Run current line
-- :.!python3

-- Run Makefile for unit test
--
-- Run unit test
--

-- Pretty print
-- json: %!jq
-- xml: xmllint --format -
-- tables: :'<,'>!column -t -s \| -o \|
-- Validate without silently changing things not according to standard.
-- https://github.com/itchyny/gojq
-- vim.highlight.range()
