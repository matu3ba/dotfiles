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
--require('my_dap') -- TODO setup one small step for vimkind
require 'my_keymaps'
vim.cmd [[colorscheme material]]
--require'colorizer'.setup()

-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
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
command! CDap :tabnew ~/.config/nvim/lua/my_dap.lua
command! CInit :tabnew ~/.config/nvim/init.lua
command! CKeymaps :tabnew ~/.config/nvim/lua/my_keymaps.lua
command! CLsp :tabnew ~/.config/nvim/lua/my_lsp.lua
command! COpts :tabnew ~/.config/nvim/lua/my_opts.lua
command! CPlugins :tabnew ~/.config/nvim/lua/my_packer.lua
command! CTele :tabnew ~/.config/nvim/lua/my_telesc.lua
command! CTree :tabnew ~/.config/nvim/lua/my_treesitter.lua
command! Bda :bufdo :bdelete
]],
  false
)
-- TODO something along require('plenary.reload').reload_module('my*', true)
-- autocmd -> file ending of unknown files: BufNewFile? BufEnter? BufAdd? BufNew?

-- :so $MYVIMRC for the lazy
-- :so stdpath('config')/lua/_packer.lua
-- type() and inspect()
-- TODO Repltikzbuild: check hash implementations in lua5.1 for incremental builds
-- xxhash has luajit implementation -> not needed, only mtime comparison

-- REPLs for latex, clippy and cpp with linker mold
--_G.Pdfmain = function()
--  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
--    _ = vim.fn.jobstop(_G.Pid_okular);
--    --assert(id == 1); fails on the second stop (the first is successful)
--    _G.Pid_okular = nil;
--  end
--  local this_tex_file = vim.fn.expand('%:p')
--  local line_number = vim.fn.line('.')
--  local okularcmd = 'okular --noraise --unique "' .. "build/main.pdf" .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
--  _ = vim.defer_fn(function()
--    _G.Pid_okular = vim.fn.jobstart(okularcmd)
--    if _G.Pid_okular <= 0 then
--      print("_G.Pid_okular: could not launch okular");
--    end
--  end, 2000)
--  do i need to start the timer?
--end
--  only 1 instance is annoying --unique
_G.Pid_okular = nil
_G.Pdfmainstart = function()
  local this_tex_file = vim.fn.expand '%:p'
  local line_number = vim.fn.line '.'
  local okularcmd = 'okular --noraise "' .. 'build/main.pdf' .. '#src:' .. line_number .. ' ' .. this_tex_file .. '"'
  _G.Pid_okular = vim.fn.jobstart(okularcmd)
  if _G.Pid_okular <= 0 then
    print '_G.Pid_okular: could not launch okular'
  end
end
_G.Pdfmainstop = function()
  if _G.Pid_okular ~= nil and _G.Pid_okular > 0 then
    _ = vim.fn.jobstop(_G.Pid_okular)
    _G.Pid_okular = nil
  end
end
_G.Pdffigure = function()
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
  local cmd = "terminal latexmk -pvc -pdflatex='lualatex --file-line-error --synctex=1' -pdf -outdir=build main.tex"
  vim.cmd 'tabnew'
  vim.cmd(cmd)
end
_G.Replpdflatex = function()
  --local cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'"
  local cmd = "terminal latexmk -pdflatex='pdflatex -file-line-error -synctex=1' -pvc -pdf -outdir=build main.tex"
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
  -- "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests'"
  local cmd =
    "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./test_pde'"
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

-- command! Pdfmain :lua Pdfmain()
vim.api.nvim_exec(
  [[
if expand('%:e') == 'tex'
  command! Pmsta :lua Pdfmainstart()
  command! Pmsto :lua Pdfmainstop()
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

-- VIMSCRIPT HACKS
-- 1. search selected region on current line
vim.api.nvim_exec(
  [[
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>
]],
  false
)

-- TODO: https://www.reddit.com/r/neovim/comments/jxub94/reload_lua_config/
-- TODO: keep track of setup scripts to install stuff (nix is long-term goal)
-- unfortunately does nix have bad error messages how to fix stuff (requires alot domain knowledge)
-- plenary.nvim => reload.lua
-- require('init.lua') for recursively loading all files

-- Snippets
-- std::cout << "type: " << typeid(eout).name() << "\n";
--
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
