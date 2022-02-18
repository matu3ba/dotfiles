-- init.lua --
-- TODO: make a table from files for later reloading the options and bindings on demand with plenary
--loading_table = ";../?.lua"
--require(loading_table)
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
--require'colorizer'.setup()

-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
_G.Clangfmt = function()
  -- looking upwards paths for a .clang-format, ideal solution would try to use root git folder
  -- TODO change once vim.fn.modified or a simple wrapper for vim.api.nvim_buf_get_changedtick(bufnr) in plenary exists
  -- => use  getbufinfo([{buf}]), bufname()
  vim.api.nvim_command [[
if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
  let cursor_pos = getpos('.')
  :%!clang-format
  call setpos('.', cursor_pos)
end
]]
end

-- extend highlighting time, remove trailing spaces except in markdown files, call Clangfmt
vim.api.nvim_exec(
  [[
augroup TESTME
autocmd!
autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
if &filetype != "markdown"
  autocmd BufWritePre * :%s/\s\+$//e
endif
autocmd BufWritePre *.h,*.hpp,*.c,*.cpp :lua Clangfmt()
augroup END
]],
  false
)

-- TODO uselua lsp formatting
-- !stylua file|folder  # looks for config in current folder
-- TODO something along require('plenary.reload').reload_module('my*', true)
-- autocmd -> file ending of unknown files: BufNewFile? BufEnter? BufAdd? BufNew?

-- :so $MYVIMRC for the lazy
-- :so stdpath('config')/lua/_packer.lua
-- type() and inspect()
-- idea Repltikzbuild: compare mtimes
-- check hash implementations in lua5.1 for incremental builds
-- xxhash has luajit implementation -> not needed, only mtime comparison

--makeglossaries main.

-- TODO: https://www.reddit.com/r/neovim/comments/jxub94/reload_lua_config/
-- idea: keep track of setup scripts to install stuff (nix is long-term goal)
-- unfortunately does nix have bad error messages how to fix stuff (requires alot domain knowledge)
-- plenary.nvim => reload.lua
-- require('init.lua') for recursively loading all files

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
