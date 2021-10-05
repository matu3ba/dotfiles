local opts = { noremap=true, silent=true }
local map = vim.api.nvim_set_keymap
-- TODO:
--    , (poor taste without special keyboard) prefix for all window operation mappings (e.g. splits, tabs, switching, file drawer etc)
--    <Space> prefix for fuzzy finding mappings (e.g. files, buffers, helptags etc)
--    s prefix for plugin operation mappings (e.g. running tests, easy motions etc)
--     \ prefix for my find and replace helpers, \ is unmapped!
--    ' is inefficient to use
--    steal+adapt telescope keymappings:
--    https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/plugin/lsp.vim

--map('n', ' ', '', opts)
--map('x', ' ', '', opts)
-- remove antipatterns --
map('', '<left>',  '<nop>', opts)
map('', '<down>',  '<nop>', opts)
map('', '<up>',    '<nop>', opts)
map('', '<right>', '<nop>', opts)
-- tab navigation --
map('n', '<C-w>t',    '<cmd>tabnew<CR>', opts) -- next,previous,specific number gt,gT,num gt
map('n', '<C-w><C-q>','<cmd>tabclose<CR>', opts)
-- session navigation <A-1> etc for switch session
-- how can I list sessions?
-- window navigation: combination <C-w> is too common to delete, ie <C-w>s/v for split and <C-w>r for swap
-- spell --
map('n', '<leader>sp', [[<cmd>lua if vim.wo.spell == false then vim.wo.spell = true; else vim.wo.spell = false; end<CR>]], opts)
-- copypasta --
map('v', '<leader>p', '"_dP', opts) -- keep pasting over the same thing
map('n', '<leader>y', '"+y', opts)
map('v', '<leader>y', '"+y', opts)
map('n', '<leader>Y', 'gg"+yG', opts)
--map('n', '<leader>c', ':nohl<CR>', opts) -- clear search highlighting --conflicts with which-key

-- dap debugger --
map('n', '<leader>db', [[<cmd>lua require'dap'.toggle_breakpoint()<CR>]], opts)
map('n', '<A-k>', [[<cmd>lua require'dap'.step_out()<CR>]], opts)
map('n', '<A-l>', [[<cmd>lua require'dap'.step_into()<CR>]], opts)
map('n', '<A-j>', [[<cmd>lua require'dap'.step_over()<CR>]], opts)
map('n', '<leader>ds', [[<cmd>lua require'dap'.stop()<CR>]], opts)
map('n', '<leader>dc', [[<cmd>lua require'dap'.continue()<CR>]], opts)
map('n', '<leader>dk', [[<cmd>lua require'dap'.up()<CR>]], opts)
map('n', '<leader>dj', [[<cmd>lua require'dap'.down()<CR>]], opts)
map('n', '<leader>d_', [[<cmd>lua require'dap'.run_last()<CR>]], opts)
map('n', '<leader>dr', [[<cmd>lua require'dap'.repl.open({}, 'vsplit')<CR><C-w>l]], opts)
map('n', '<leader>di', [[<cmd>lua require'dap.ui.variables'.hover()<CR>]], opts)
map('n', '<leader>dvi', [[<cmd>lua require'dap.ui.variables'.visual_hover()<CR>]], opts)
map('n', '<leader>d?', [[<cmd>lua require'dap.ui.variables'.scopes()<CR>]], opts)
map('n', '<leader>de', [[<cmd>lua require'dap'.set_exception_breakpoints({"all"})<CR>]], opts)
map('n', '<leader>da', [[<cmd>lua require'debugHelper'.attach()<CR>]], opts)
map('n', '<leader>dA', [[<cmd>lua require'debugHelper'.attachToRemote()<CR>]], opts)
-- visual dap --
--map('n', <leader>di, [[<cmd>lua require'dap.ui.widgets'.hover()<CR>]], opts)
--map('n', <leader>d?, [[<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>]], opts)
--Plug 'nvim-telescope/telescope-dap.nvim'
--lua << EOF
--require('telescope').setup()
--require('telescope').load_extension('dap')
--EOF
--nnoremap <leader>df :Telescope dap frames<CR>
--nnoremap <leader>dc :Telescope dap commands<CR>
--nnoremap <leader>db :Telescope dap list_breakpoints<CR>
--theHamsta/nvim-dap-virtual-text and mfussenegger/nvim-dap
--let g:dap_virtual_text = v:true
--Plug 'rcarriga/nvim-dap-ui'
--lua require("dapui").setup()
--nnoremap <leader>dq :lua require("dapui").toggle()<CR>

-- color switching --
map('n', '<leader>m', [[<cmd>lua require('material.functions').toggle_style()<CR>]], opts) -- switch material style
-- lspconfig --
map('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts)           -- switch header_source
--  switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
--map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts) -- conflicting
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)           -- **g**oto definition
--map('n', 'gDD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)   -- gt, gT used for tabnext
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)       -- **g**oto signature
-- no equivalent of lsp_finder
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)               -- **g**oto rename
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)                 -- Kimme_info
map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)  -- code action
map('n', '<leader>cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts) -- line diagnostics
map('n', '<leader>rf', '<cmd>lua vim.lsp.buf.references()<CR>', opts)   -- references
map('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)     -- next error
map('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)     -- previous error
-- impl
--map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

-- trouble  -- redundant to telescope
--map("n", "<leader>xx", "<cmd>LspTroubleToggle<cr>", opts)
--map("n", "<leader>xw", "<cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>", opts)
--map("n", "<leader>xd", "<cmd>LspTroubleToggle lsp_document_diagnostics<cr>", opts)
--map("n", "<leader>xl", "<cmd>LspTroubleToggle loclist<cr>", opts)
--map("n", "<leader>xq", "<cmd>LspTroubleToggle quickfix<cr>", opts)
--map("n", "<leader>xr", "<cmd>LspTrouble lsp_references<cr>", opts)
-- telescope -- fuzzy_match 'extact_match ^prefix-exact suffix_exact$ !inverse_match
map('n', '<leader>tb',   [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)              -- buffers
map('n', '<leader>ts',   [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts) -- document symbols
map('n', '<leader>tS',   [[<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>]], opts) -- workspace symbols (bigger)
map('n', '<leader>ff',  [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts)            -- find files
map('n', '<leader>gf',  [[<cmd>lua require('telescope.builtin').git_files()<CR>]], opts)             -- git files
--.grep_string({ search = vim.fn.input("Grep For > ")})
map('n', '<leader>rg',  [[<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>]], opts) -- ripgrep string
map('n', '<leader>th',   [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts)                                      -- helptags
map('n', '<leader>pr',   [[<cmd>lua require'telescope'.extensions.project.project{}<CR>]], opts) -- project: d, r, c, s(in your project), w(change dir without open), f
map('n', '<leader>z',   [[<cmd>lua require'telescope'.extensions.z.list{ cmd = { vim.o.shell, '-c', 'zoxide query -sl' } }<CR>]], opts) -- zoxide

map('n', '<leader>ed', [[<cmd>lua require'telescope'.extensions.project-scripts.edit{}<CR>]], opts)  -- edit_script
--map('n', '<leader>ex', [[<cmd>lua require'telescope'.extensions.project-scripts.run{}<CR>]], opts)

-- buffer navigation
-- harpoon
--nnoremap <leader>j :lua require("harpoon.ui").nav_file(1)<CR>
--nnoremap <leader>k :lua require("harpoon.ui").nav_file(2)<CR>
--nnoremap <leader>l :lua require("harpoon.ui").nav_file(3)<CR>
--nnoremap <leader>; :lua require("harpoon.ui").nav_file(4)<CR>
--nnoremap <leader>mm :lua require("harpoon.mark").add_file()<CR>
--nnoremap <leader>mc :lua require("harpoon.mark").clear_all()<CR>
--nnoremap <leader>mj :lua require("harpoon.mark").set_current_at(1)<CR>
--nnoremap <leader>mk :lua require("harpoon.mark").set_current_at(2)<CR>
--nnoremap <leader>ml :lua require("harpoon.mark").set_current_at(3)<CR>
--nnoremap <leader>m; :lua require("harpoon.mark").set_current_at(4)<CR>
--nnoremap <leader>mv :lua require("harpoon.ui").toggle_quick_menu()<CR>
--nnoremap <leader>mrj :lua require("harpoon.mark").rm_file(1)<CR>
--nnoremap <leader>mrk :lua require("harpoon.mark").rm_file(2)<CR>
--nnoremap <leader>mrl :lua require("harpoon.mark").rm_file(3)<CR>
--nnoremap <leader>mr; :lua require("harpoon.mark").rm_file(4)<CR>
-- nnn --
--TODO convert setup to lua

