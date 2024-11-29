--! Main entry point, very common things and autocommands
-- luacheck: globals vim
-- luacheck: no max line length
vim.filetype.add {
  extension = {
    smd = 'supermd',
    shtml = 'superhtml',
    ziggy = 'ziggy',
    ['ziggy-schema'] = 'ziggy_schema',
  },
}

require 'my_opts'
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/.local/share/nvim/lazy/lazy.nvim
-- git clone --filter=blob:none --single-branch https://github.com/folke/lazy.nvim.git $HOME/AppData/Local/nvim-data/lazy/lazy.nvim
-- cp -rf $HOME/dotfiles/.config/nvim $HOME/AppData/Local/nvim
-- cp -r -fo $HOME\dotfiles\.config\nvim $HOME\AppData\Local
-- Copy-Item -Recurse -Force -Path $HOME/dotfiles/.config/nvim -Destination $HOME/AppData/Local
-- :lua print(vim.inspect(vim.api.nvim_list_runtime_paths()))
-- vim.opt.runtimepath:get(), :h vim.opt
-- vim.opt.rtp:append()
-- set environment variable NVIM_APPNAME to use $XDG_CONFIG_HOME/NVIM_APPNAME
-- NVIM_APPNAME=nvim is implicit, iff NVIM_APPNAME is not defined.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- local has_lazy = vim.uv.fs_stat(lazypath)
-- workaround git commit failure
local has_lazy = vim.loop.fs_stat(lazypath)
if not has_lazy then
  print 'Please install lazy, instructions in init.lua'
else
  vim.opt.runtimepath:prepend(lazypath)
  -- workaround https://github.com/natecraddock/telescope-zf-native.nvim/issues/21
  require('lazy').setup('my_plugins', { rocks = { enabled = false } })
  -- Portable CI, focus on Linux (mostly ssh + load balancing setup)
  -- idea: https://github.com/stevearc/overseer.nvim/issues/203#issuecomment-1734841561
  -- Windows unsolved (beyond wine)
  -- 1. coredumps + 2. debug symbols + 3. live attach etc
  -- qemu user documentation is created for support contracts, not user friendly-ness

  -- TODO windowing
  -- * 1. :tabm shortcuts        hydra tab mode
  -- * 2. combine commands to replace terminal buffer
  -- * 3. implement sharing cmds between overseer and shell (via registers?)
  -- * 4. luasnips setup to create snippets for common stuff
  -- * 5. vim macro capture groups https://pabloariasal.github.io/2020/04/25/vim-is-for-the-lazy/
  -- "Seven habits of effective text editing" by Bram Moolenaar

  -- TODO https://dev.to/vonheikemen/lazynvim-how-to-revert-a-plugin-back-to-a-previous-version-1pdp
  -- idea config: setup NeoComposer

  -- idea https://github.com/birth-software/birth
  -- idea advanced gdb to test signaling + reliable attaching of gdb to a process

  -- idea NixOS configs https://github.com/sebastiant/dotfiles
  -- idea web search via shell
  -- idea walk through https://www.youtube.com/@devopstoolbox/videos
  -- idea walk through https://github.com/bregman-arie/devops-exercises
  -- TODO implement most of https://bluz71.github.io/2021/09/10/vim-tips-revisited.html
  -- * \ prefix for find and replace helpers
  --   + also do them
  -- * ; as prefix for runners
  -- * wrapping breakindent
  -- * substitute visual block
  -- * goto other end of visual selection with o
  -- * make dot work on visual selections
  -- * execute macro over visual selection
  -- * clone current paragraph
  -- * rotate tabs: tabm0

  -- idea email setup Kernel development mutt http://kroah.com/log/blog/2019/08/14/patch-workflow-with-mutt-2019/
  -- or https://webgefrickel.de/blog/a-modern-mutt-setup but there seem to be no significant advantages (no lua etc)
  -- idea
  -- https://github.com/gto76/linux-cheatsheet
  -- https://github.com/gto76/python-cheatsheet
  -- container and sandboxing cheat sheet

  -- idea https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/
  -- https://stackoverflow.com/questions/60866833/vim-compiling-a-c-program-and-displaying-the-output-in-a-tab
  -- try https://github.com/cipharius/kakoune-arcan
  -- idea https://super-cress-98d.notion.site/Run-zig-test-in-neovim-cde72b0634b449bc815211c6ca1032a4
  -- idea keybindings for sending to terminal to gdb

  require 'my_utils'

  require 'my_telesc' -- more flexible
  if vim.fn.has 'win32' ~= 1 then
    require 'my_jfind' -- faster than telescope
  end
  require 'my_gitsign' -- git
  -- require 'my_diffview' -- cycle through diffs for modified files and git rev
  require 'my_hydra' -- multi_mode
  require 'my_dap' -- :lua= require("dap").session().capabilities.supportsCompletionsRequest
  -- neodev setup is in my_dap
  require 'my_lsp' -- setup in my_nvimcmp.lua
  require 'my_lint' -- setup in my_lint.lua
  require 'my_statusline' -- statusline
  require 'my_over' -- runner
  require 'my_surround' -- text_surround
  require 'my_aerial' -- overview_window
  require 'my_oil' -- file_explorer
  require 'my_fmt' -- smart_formatter
  require 'my_treesitter' -- smart_formatter

  -- workaround lazy caching init.lua loading, but the module might be absent.
  local has_libbuf, _ = pcall(require, 'libbuf')
  if has_libbuf then require 'my_buf' end

  --==lazy fast restore state from https://dev.to/vonheikemen/lazynvim-how-to-revert-a-plugin-back-to-a-previous-version-1pdp
  local aucmds_lazy = vim.api.nvim_create_augroup('aucmds_lazy', { clear = true })
  local lazy_snapshot_dir = vim.fn.stdpath 'data' .. '/lazy_snapshot'
  local lockfile = vim.fn.stdpath 'config' .. '/lazy-lock.json'
  vim.api.nvim_create_user_command('BrowseSnapshots', 'edit ' .. lazy_snapshot_dir, {})
  vim.api.nvim_create_autocmd('User', {
    group = aucmds_lazy,
    pattern = 'LazyUpdatePre',
    desc = 'Backup lazy.nvim lockfile',
    callback = function()
      vim.fn.mkdir(lazy_snapshot_dir, 'p')
      local snapshot = lazy_snapshot_dir .. os.date '/%Y-%m-%dT%H:%M:%S.json'
      vim.loop.fs_copyfile(lockfile, snapshot)
    end,
  })
end

require 'my_cmds'
require 'my_keymaps'
--require 'my_nvimcmp'

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
--
-- idea project: reduze with getting AST<->source locations

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
-- Run macros
-- * until the end of the file: :.,$norm! @a
-- * for every line of a paragraph: :g/.+/norm! @a

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
-- Instead of .* use .\{-}, for example %s/style=".\{-}"//g to remove occurrences of style="..."
-- https://stackoverflow.com/questions/1305853/how-can-i-make-my-match-non-greedy-in-vim
-- another option for multiple matches is :%s/\v(style|class)\=".{-}"//g
-- To match escaped string symbols of JSON use /\\".\{-}\\"
-- and not /\\".*\\"
-- literal substitution requires very non magic mode https://stackoverflow.com/a/46235399
-- replacement with argument:
-- %s/\(.\)word/replacement \1
-- idea: selection + substitute selection with (simplify)
-- fast select full function: va{V      no}

-- read as latin :edit ++enc=latin1 filename
-- read + write as latin
-- :edit ++encoding=latin1 filepath
-- :set fileencoding=latin1
-- Looks like .editorconfig breaks behavior, so disable it via
-- :lua vim.g.editorconfig = false
-- or use nodepad++.
-- Best to use git bash with 'file -i' and 'iconv -f from -t to' to reencode
-- and use for example msvc in strict utf8 mode to prevent bad behavior.
-- Writing may need :bd filepath
-- :set encoding - set the encoding used to read the file (not working for some reason)
-- :set fileencoding - show and set the encoding to use when saving the file
-- :set termencoding - show and set the encoding to use to display characters to your terminal

-- stylua: ignore start
local aucmds_graphics = vim.api.nvim_create_augroup('aucmds_graphics',  {clear = true})
-- extend highlighting time
vim.api.nvim_create_autocmd('TextYankPost', {group = aucmds_graphics, pattern = '*', callback = function() require'vim.highlight'.on_yank({timeout = 100}) end})
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
-- `:lua = vim.fs`, `:lua = x` (short forms of `:lua vim.print(vim.fs)`)
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
-- :lua file = assert(io.open("tmpfile123", "a")); file:write(vim.o.backup); file:close()
-- :lua file = assert(io.open("tmpfile123", "a")); file:write(vim.inspect(vim.o.backup)); file:close()

-- Debugging message sources.
-- local original = vim.notify
-- ---@diagnostic disable-next-line: duplicate-set-field
-- vim.notify = function(msg, level, opts)
--   local fp = assert(io.open('/tmp/tmpfile', 'w')) --DEBUG
--   fp:write(msg) --DEBUG
--   fp:write '\n' --DEBUG
--   fp:close() --DEBUG
--   if msg == 'No code actions available' then return end
--   original(msg, level, opts)
-- end

-- Debugging Neovim with vimscript via writing settings to file
-- :call writefile([], './tmpfile123')
-- :call writefile(split(g:material_lighter_contrast, "\n", 1), glob('./tmpfile123'), 'b')
-- Execute something and add it to current buffer.
-- :put = execute('messages')
-- Debugging Environment variables
-- :redir @a
-- :fancy command
-- :redir END
-- :messages
-- visual mode: "ap

-- :redir >name_of_registers_file
-- :registers
-- :redir END
-- :r name_of_registers_file
-- :help redir

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

-- C-r C-o/C-r C-r register: paste text literally
-- C-r register: pasting from register
-- set number, set nonumber `set nu!`, likewise `set rnu!`
-- set all to list all settings

-- normal list to array list
-- :%s/.*/"&",
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
-- convert linux line ending to windows:
-- :%s//\r/g
-- convert tabs to spaces:
-- :retab
-- Convert '\n's to newline characters
-- %s/\\n/\r/g
-- Convert newline characters to '\n's:
-- %s/\n/\\n/g
-- convert command with space to newline with \
-- / / \\\r/g
-- convert back cmd separated by \ to space separated commands
-- /\\\n/ /
-- show hex symbols: nvim -b FILE
-- convert symbols into hex: !%xxd
-- reverse convert (before saving): :%!xxd -r
-- show non-text ascii symbols with :ascii

-- make-path
-- :!mkdir -p somepath\somefile

-- std::cout << "dbg1\n"; // DEBUG
-- search with /.*DEBUG$
-- delete with :g/.*DEBUG$/del
-- delete empty lines with :g/^$/del

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
--
-- Github issue url maker command
-- :%s/(#\(\d\+\))/(<a href="https:\/\/github.com\/ziglang\/zig\/issues\/\1">#\1<\/a>)/g
