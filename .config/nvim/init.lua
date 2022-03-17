-- init.lua --
require 'my_globals'
require 'my_packer'
require 'my_opts'
require 'my_lsp'
require 'my_telesc'
--require('my_treesitter') -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
--require('my_dap') -- idea setup one small step for vimkind
require 'my_keymaps'
require 'my_cmds'
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

-- stylua: ignore start
-- extend highlighting time, remove trailing spaces except in markdown files, call Clangfmt
vim.api.nvim_create_augroup('MYAUCMDS',  {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {group = 'MYAUCMDS', pattern = '*', callback = function() require'vim.highlight'.on_yank({timeout = 100}) end})
vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = '*', command = [[:%s/\s\+$//e]]}) -- remove trailing spaces
vim.api.nvim_create_autocmd('BufWritePre', {group = 'MYAUCMDS', pattern = { '*.h', '*.hpp', '*.c', '*.cpp' }, command = [[:lua Clangfmt()]]})
-- stylua: ignore end

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

-- :h builtin-function-list

-- Debugging
-- :g/.*DEBUG$/del
-- local fp = assert(io.open("/tmp/tmpfile", "w")) --DEBUG
-- for index,tables in pairs(repo_paths) do        --DEBUG
--   fp:write(index)                               --DEBUG
--   fp:write(", ")                                --DEBUG
--   fp:write(tables)                              --DEBUG
--   fp:write("\n")                                --DEBUG
-- end                                             --DEBUG
-- fp.close()                                      --DEBUG

-- local fp = assert(io.open("/tmp/tmpfile", "w")) --DEBUG
-- for index,tables in ipairs(repo_paths) do       --DEBUG
--   fp:write(index)                               --DEBUG
--   fp:write(", ")                                --DEBUG
--   fp:write(tostring(tables))                    --DEBUG
--   fp:write("\n")                                --DEBUG
-- end                                             --DEBUG
-- fp.close()                                      --DEBUG

-- std::cout << "dbg1\n"; // DEBUG
-- search with /.*DEBUG$
-- delete with :g/.*DEBUG$/del

-- ./runTests --gtest_filter='minimalz3.*'
-- gdb --ex run --args ./test_pde --gtest_filter='Nestout.*' --gtest_break_on_failure
-- set follow-fork-mode mode
