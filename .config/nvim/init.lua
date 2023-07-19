--! Main entry point, very common things and autocommands
-- luacheck: globals vim
-- luacheck: no max line length
require 'my_opts'
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/.local/share/nvim/lazy/lazy.nvim
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/AppData/Local/nvim-data/lazy/lazy.nvim
-- cp -r $HOME/dotfiles/.config/nvim $HOME/AppData/Local/nvim
-- treesitter languages may require: cargo install tree-sitter-cli
-- :lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))
-- vim.opt.runtimepath:get(), :h vim.opt
-- vim.opt.rtp:append()
-- set environment variable NVIM_APPNAME to use $XDG_CONFIG_HOME/NVIM_APPNAME
-- NVIM_APPNAME=nvim is implicit, if NVIM_APPNAME is not defined.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- local has_lazy = vim.uv.fs_stat(lazypath)
-- workaround git commit failure
local has_lazy = vim.loop.fs_stat(lazypath)
if not has_lazy then
  print 'Please install lazy, instructions in init.lua'
else
  vim.opt.runtimepath:prepend(lazypath)
  require('lazy').setup('my_plugins', {})
  -- TODO NixOS configs https://github.com/sebastiant/dotfiles,
  -- TODO setup https://arcan-fe.com within (NixOS xor chimera linux) + experiment with neovim shell commands
  -- TODO extract hardening flags from https://blog.mayflower.de/5800-Hardening-Compiler-Flags-for-NixOS.html
  -- TODO add missing features of https://bluz71.github.io/2023/06/02/maximize-productivity-of-the-bash-shell.html
  -- TODO implement most of https://bluz71.github.io/2021/09/10/vim-tips-revisited.html
  -- TODO config: add missing pcalls/checks in treesitter and telescope-fzf-native
  -- TODO config: show size of last copy + selection in cmdline
  -- TODO config: show context of functions, either via vim or via lua regex
  -- TODO open source ascii editor, ideally within neovim. inspiration https://monodraw.helftone.com/
  -- idea setup mutt http://kroah.com/log/blog/2019/08/14/patch-workflow-with-mutt-2019/
  -- or https://webgefrickel.de/blog/a-modern-mutt-setup but there seem to be no significant advantages (no lua etc)
  --
  -- TODO get better keyboard, for example ultimate hacker's keyboard

  -- idea https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/
  -- https://stackoverflow.com/questions/60866833/vim-compiling-a-c-program-and-displaying-the-output-in-a-tab
  -- try https://github.com/cipharius/kakoune-arcan
  -- idea https://super-cress-98d.notion.site/Run-zig-test-in-neovim-cde72b0634b449bc815211c6ca1032a4
  -- idea keybindings for sending to terminal to gdb

  require 'my_dap'  -- :lua= require("dap").session().capabilities.supportsCompletionsRequest
  require 'my_treesitter' -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
  require 'my_telesc' -- more flexible
  require 'my_jfind' -- faster than telescope
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
-- vim.api.nvim_call_function("stdpath", { "cache" })
_G.Clangfmt = function()
  vim.api.nvim_exec2([[
if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
  let cursor_pos = getpos('.')
  :%!clang-format
  call setpos('.', cursor_pos)
end
]], {})
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
-- TODO project: testing lib to build + test + spawn suite with optional debugging vs simulation
-- idea project: reduze with getting AST<->source locations
-- idea: https://jdhao.github.io/2020/11/15/nvim_text_objects/
--       and https://github.com/nvim-treesitter/nvim-treesitter-textobjects

-- working with macros
-- https://stackoverflow.com/questions/2024443/saving-vim-macros
-- macros are stored in the regular registers and can be pasted or executed
-- explicit writing of macro content: let @a='0fa'
-- NOTE: use C-r C-r to insert contents of the a register to prevent execution on pasting!
-- Appending macros of register a with qA..q
-- @@ replays last macro
-- @: replays last command
-- Formatting is slow
-- Solution:
-- select comments + press gq
-- press = on selection, see :h =

-- Problem: Macros are slow.something slows down macro execution
-- Solutions:
-- :TSDisable wxyz,
-- :set lazyredraw
-- :noa normal 10000@q
-- :LspStop,
-- :lua require('cmp').setup.buffer { enabled = false }
-- or use vanilla vim

-- Problem: External command break vim cmd sequence, neither :ex '%!d' | w nor :%!d | w work.
-- Solution: !echo > %, windows !echo. > %
-- Solution including discarding local changes :e! | !echo > %

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
-- idea: selection + substitute selection with (simplify)
-- fast select full function: va{V      no}

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

-- setups after special keypress
-- 1. load treesitter cmd: :LoT
-- 2. toggle autocmds?
-- 3. unload all bloat cmd: :LoQ
-- 4. ??

-- very verbose
-- local has_plenary, plenary = pcall(require, 'plenary')
-- if has_plenary then
--   -- Runs clangfmt on the whole file.
--   local clangfmt = function()
--     if vim.bo.modified then
--       local abs_fname = vim.api.nvim_buf_get_name(0)
--       for dir in vim.fs.parents(abs_fname) do
--         local abs_clangfmt = dir .. "/.clang-format"
--         local fh = io.open(abs_clangfmt, "r")
--         local file_exists = fh ~= nil
--         if file_exists then
--           io.close(fh)
--           local cursor_pos = vim.api.nvim_win_get_cursor(0)
--           local content = vim.api.nvim_buf_get_lines()
--           local plenary_run = plenary.job:new { command = 'clang-format', args = { "-i", abs_fname } }
--           local result = plenary_run:sync()
--           -- result checking etc
--           vim.api.nvim_buf_set_lines(result)
--           if plenary_run.code ~= 0 then print [[clangfmt had warning or error. Run ':%!clang-format']] end
--           vim.api.nvim_win_set_cursor(0, cursor_pos)
--           return
--         end
--       end
--     end
--   end
--   vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = { '*.h', '*.hpp', '*.c', '*.cpp' }, callback = function() clangfmt() end})
-- end
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
-- set number, set nonumber `set nu!`, likewise `set rnu!`
-- set all to list all settings

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
-- show hex symbols: nvim -b FILE
-- convert symbols into hex: !%xxd
-- reverse convert (before saving): :%!xxd -r
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
