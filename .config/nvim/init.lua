-- init.lua --
-- TODO: make a table from files for later reloading the options and bindings on demand with plenary
require('_packer')
require('_opts')
require('_lsp')
require('_telesc')
--require('_treesitter') -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
--require('_dap') -- TODO setup one small step for vimkind
require('_keymaps')
vim.cmd[[colorscheme material]]
--require'colorizer'.setup()

-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
--vim.fn.getpos
-- vim.fn.expand('%:p:h')
-- vim.fn.expand('%:p:~:.:h') vim.fn.fnamemodify
Clangfmt = function()
-- looking upwards paths for a .clang-format, ideal solution would try to use root git folder
vim.api.nvim_command([[
if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
  let cursor_pos = getpos('.')
  :%!clang-format
  call setpos('.', cursor_pos)
end
]])
end

--Styluafmt = function()
---- hardcoding formatting option for not needing a config file
---- single quote and emptyspace are consisently readable independ of editor
--vim.api.nvim_command([[
--if &modified
--  let cursor_pos = getpos('.')
--  :!stylua --indent-type Spaces --quote-style AutoPreferSingle %
--  call setpos('.', cursor_pos)
--end
--]])
--end

-- extend highlighting time, remove trailing spaces except in markdown files, call Clangfmt
vim.api.nvim_exec([[
augroup TESTME
autocmd!
autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
if &filetype != "markdown"
  autocmd BufWritePre * :%s/\s\+$//e
endif
autocmd BufWritePre *.h,*.hpp,*.c,*.cpp :lua Clangfmt()
"autocmd BufWritePre *.lua :lua Styluafmt()
augroup END
]], false)

-- Load configuration files and delete all but current buffer
vim.api.nvim_exec([[
command! CDap :tabnew ~/.config/nvim/lua/_dap.lua
command! CInit :tabnew ~/.config/nvim/init.lua
command! CKeymaps :tabnew ~/.config/nvim/lua/_keymaps.lua
command! CLsp :tabnew ~/.config/nvim/lua/_lsp.lua
command! COpts :tabnew ~/.config/nvim/lua/_opts.lua
command! CPlugins :tabnew ~/.config/nvim/lua/_packer.lua
command! CTele :tabnew ~/.config/nvim/lua/_telesc.lua
command! CTree :tabnew ~/.config/nvim/lua/_treesitter.lua
command! Bda :bufdo :bdelete -- deleting all buffers except current one
]], false)

-- :so $MYVIMRC for the lazy
-- :so stdpath('config')/lua/_packer.lua
-- type() and inspect()
-- TODO add telescope-project integration

-- REPLs for latex, clippy and cpp with linker mold
vim.api.nvim_exec([[
function! Latexmklualatex()
  let l:cmd = "terminal watchexec -e tex 'latexmk -pdflatex=lualatex -pdf -outdir=build main.tex'" | tabnew | execute cmd
endfunction
function! Latexmkpdflatex()
  let l:cmd = "terminal watchexec -e tex 'latexmk -pdf -outdir=build main.tex'" | tabnew | execute cmd
endfunction
function! Cargoclippy()
  let l:cmd = "terminal watchexec -e rs 'cargo +nightly test --lib && bash tests/run_examples.sh && cargo +1.53.0 clippy --all-targets --all-features -- -D warnings &> clippy.log'" | tabnew | execute cmd
endfunction
function! CargocheckAll()
  let l:cmd = "terminal watchexec -e rs 'cargo +nightly test --lib && bash tests/run_examples.sh && cargo check --all-targets --all-features'" | tabnew | execute cmd
endfunction
function! Cargocheck()
  let l:cmd = "terminal watchexec -e rs 'cargo +nightly check'" | tabnew | execute cmd
endfunction
function! Test123()
  let l:cmd = "terminal echo ${HOME}" | tabnew | execute cmd
endfunction
function! ReplpdeAll()
  let l:cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'" | tabnew | execute cmd
endfunction
function! ReplpdeTest()
  let l:cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'" | tabnew | execute cmd
endfunction
function! ReplpdeTestgdb()
  let l:cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst 'make -j8 && gdb -ex run ./runTests'" | tabnew | execute cmd
endfunction
command! ReplpdeAll :call Replpde()
command! ReplpdeTest :call ReplpdeTest()
command! ReplpdeTestgdb :call ReplpdeTest()
function! Buildpde()
  let l:cmd = "terminal cd build; watchexec -w ../in -w ../src -w ../tst '$HOME/dev/git/cpp/mold/mold -run make -j8'" | tabnew | execute cmd
endfunction
command! Test123 :call Test123()
command! Buildpde :call Buildpde()
if expand('%:e') == 'tex'
  "command! Buildlatex :call Latexmklualatex()
  command! Buildlatex :call Latexmkpdflatex()
  "command! Pdf :call jobstart(["okular", "build/" . expand("%:t:r") . ".pdf"])
  command! Pdf :call jobstart(["okular", "build/main.pdf"])
endif
if expand('%:e') == 'rs'
  command! Cargoclippy :call Cargoclippy()
  command! Cargocheck :call Cargocheck()
  "export RUSTFLAGS="-Z macro-backtrace"
  command! Cargofmt :tabnew \| !cargo +nightly fmt
  command! Cargotest :tabnew \| !cargo +nightly test --lib && bash tests/run_examples.sh
endif
]], false)

-- TODO: https://www.reddit.com/r/neovim/comments/jxub94/reload_lua_config/
-- TODO: keep track of setup scripts to install stuff (nix is long-term goal)
-- unfortunately does nix have bad error messages how to fix stuff (requires alot domain knowledge)
-- plenary.nvim => reload.lua

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
