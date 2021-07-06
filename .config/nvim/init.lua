-- init.lua --
require('_packer')
require('_opts')
require('_lsp')
require('_telesc')
require('_treesitter') -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s
require('_compe')
require('_keymaps')
require'colorizer'.setup()

clangfmt = function()
-- looking upwards paths for a .clang-format, ideal solution would use root git folder
vim.api.nvim_command([[
if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
  let cursor_pos = getpos('.')
  :%!clang-format
  call setpos('.', cursor_pos)
end
]])
end

-- extend highlighting time, remove trailing spaces except in markdown files, call clangfmt
vim.api.nvim_exec([[
augroup TESTME
autocmd!
autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 100})
if &filetype != "markdown"
  autocmd BufWritePre * :%s/\s\+$//e
endif
autocmd BufWritePre *.h,*.hpp,*.c,*.cpp :lua clangfmt()
augroup END
]], false)

-- Load configuration files and delete all but current buffer
vim.api.nvim_exec([[
command! CInit :tabnew ~/.config/nvim/init.lua
command! CKeymaps :tabnew ~/.config/nvim/lua/_keymaps.lua
command! CLsp :tabnew ~/.config/nvim/lua/_lsp.lua
command! COpts :tabnew ~/.config/nvim/lua/_opts.lua
command! CPlugins :tabnew ~/.config/nvim/lua/_packer.lua
command! CTree :tabnew ~/.config/nvim/lua/_treesitter.lua
command! Bda :bufdo :bdelete -- deleting all buffers except current one
]], false)

-- setup REPLs for latex, clippy and cpp with linker mold
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
function! Cargocheck()
  let l:cmd = "terminal watchexec -e rs 'cargo +nightly test --lib && bash tests/run_examples.sh && cargo check --all-targets --all-features'" | tabnew | execute cmd
endfunction
function! Buildpde()
  let l:cmd = "terminal cd Debug; watchexec -w ../src -w ../tst '${HOME}/dev/git/cpp/mold/mold -run make -j8 && ./runTests && ./pde'" | tabnew | execute cmd
endfunction
command! Buildpde :call Buildpde()
if expand('%:e') == 'tex'
  "command! Buildauto :call Latexmklualatex()
  command! Buildauto :call Latexmkpdflatex()
  command! Pdf :call jobstart(["okular", "build/" . expand("%:t:r") . ".pdf"])
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
-- plenary.nvim => reload.lua

--this is BROKEN somehow
--vim.g['nnn#action'] = {
--'<c-t> : tab split',
--'<c-x> :     split',
--'<c-v> :    vsplit'
--}
--vim.api.nvim_set_var('nnn#action', [[{'<C-t>':'tab split','<C-x':'split','<C-v>':'vsplit'}]])
--vim.api.nvim_exec([[
--let g:nnn#action = {
--      \ '<c-t>': 'tab split',
--      \ '<c-x>': 'split',
--      \ '<c-v>': 'vsplit' }
--      ]])

-- Snippets
-- std::cout << "type: " << typeid(eout).name() << "\n";
