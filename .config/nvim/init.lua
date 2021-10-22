-- init.lua --
-- TODO: make a table from files for later reloading the options and bindings on demand with plenary
require 'my_globals'
require 'my_packer'
require 'my_opts'
require 'my_lsp'
require 'my_telesc'
--require('my_treesitter') -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
--require('my_dap') -- TODO setup one small step for vimkind
require 'my_keymaps'
vim.cmd [[colorscheme material]]
--require'colorizer'.setup()

-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.getpos, vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
_G.Clangfmt = function()
  -- looking upwards paths for a .clang-format, ideal solution would try to use root git folder
  -- TODO change once vim.fn.modified or a simple wrapper for vim.api.nvim_buf_get_changedtick(bufnr) in plenary exists
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

-- Load configuration files and delete all but current buffer
-- Bda: deleting all buffers except current one
-- !stylua file|folder  # looks for config in current folder
vim.api.nvim_exec(
  [[
command! CDap :tabnew ~/.config/nvim/lua/_dap.lua
command! CInit :tabnew ~/.config/nvim/init.lua
command! CKeymaps :tabnew ~/.config/nvim/lua/_keymaps.lua
command! CLsp :tabnew ~/.config/nvim/lua/_lsp.lua
command! COpts :tabnew ~/.config/nvim/lua/_opts.lua
command! CPlugins :tabnew ~/.config/nvim/lua/_packer.lua
command! CTele :tabnew ~/.config/nvim/lua/_telesc.lua
command! CTree :tabnew ~/.config/nvim/lua/_treesitter.lua
command! Bda :bufdo :bdelete
]],
  false
)
-- TODO require('plenary.reload').reload_module('my', true)

-- :so $MYVIMRC for the lazy
-- :so stdpath('config')/lua/_packer.lua
-- type() and inspect()
-- TODO add telescope-project integration
-- TODO Repltikzbuild: check hash implementations in lua5.1 for incremental builds
-- xxhash has luajit implementation

-- REPLs for latex, clippy and cpp with linker mold
_G.Pdfmain = function()
  vim.fn.jobstart 'okular build/main.pdf'
end
_G.Pdffigure = function()
  vim.fn.jobstart('okular figures/' .. vim.fn.expand '%:t:r' .. '.pdf')
end
_G.Tikzbild = function()
  vim.fn.jobstart('okular figures/' .. vim.fn.expand '%:t:r' .. '.pdf')
end

_G.Repltikzthis = function()
  local bashcmd = [[cd figures; watchexec -w ]]
    .. vim.fn.expand '%:t'
    .. [[ "lualatex --shell-escape '\def\zzz{']]
    .. vim.fn.expand '%:t'
    .. [['} \input myscript.tex'"]]
  --print(bashcmd)
  local cmd = 'terminal ' .. bashcmd
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Repltikzall = function()
  local cmd = "terminal cd figures; watchexec -e tikz './build_tikz.sh'"
  print(cmd)
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Repllualatex = function()
  local cmd = "terminal watchexec -e tex 'latexmk -pdflatex=lualatex -pdf -outdir=build main.tex'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Replpdflatex = function()
  local cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end

_G.ReplpdeAll = function()
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.ReplpdeTest = function()
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.ReplpdeTestgdb = function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst 'make -j8 && gdb -ex run ./runTests'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Buildpde = function()
  local cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8'"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Test123 = function()
  local cmd = 'terminal echo ${HOME}'
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end

vim.api.nvim_exec(
  [[
if expand('%:e') == 'tex'
  command! Pdfmain :lua Pdfmain()
  command! Pdffigure :lua Pdffigure()
  command! Repllualatex :lua Repllualatex()
  command! Replpdflatex :lua Replpdflatex()
  command! Repltikzall :lua Repltikzall()
  command! Repltikzthis :lua Repltikzthis()
endif
command! ReplpdeAll :lua Replpde()
command! ReplpdeTest :lua ReplpdeTest()
command! ReplpdeTestgdb :lua ReplpdeTest()
command! Buildpde :lua Buildpde()
command! Test123 :lua Test123()
]],
  false
)

-- TODO: https://www.reddit.com/r/neovim/comments/jxub94/reload_lua_config/
-- TODO: keep track of setup scripts to install stuff (nix is long-term goal)
-- unfortunately does nix have bad error messages how to fix stuff (requires alot domain knowledge)
-- plenary.nvim => reload.lua
--require('init.lua') for recursively loading all files

-- Search for visually selected text (no multiline)
--vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

-- Snippets
-- std::cout << "type: " << typeid(eout).name() << "\n";

-- local fp = assert(io.open("/tmp/tmpfile", "w"))
-- for index,tables in pairs(repo_paths) do
--   fp:write(index)
--   fp:write(", ")
--   fp:write(tables)
--   fp:write("\n")
-- end
-- fp.close()

-- local fp = assert(io.open("/tmp/tmpfile", "w"))
-- for index,tables in ipairs(repo_paths) do
--   fp:write(index)
--   fp:write(", ")
--   fp:write(tostring(tables))
--   fp:write("\n")
-- end
-- fp.close()
