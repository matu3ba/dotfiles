local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', ' ', '', opts)
vim.api.nvim_set_keymap('x', ' ', '', opts)
-- remove antipatterns --
vim.api.nvim_set_keymap('', '<left>',  '<nop>', opts)
vim.api.nvim_set_keymap('', '<down>',  '<nop>', opts)
vim.api.nvim_set_keymap('', '<up>',    '<nop>', opts)
vim.api.nvim_set_keymap('', '<right>', '<nop>', opts)
-- tab navigation --
vim.api.nvim_set_keymap('n', '<leader>j', '<cmd>tabprevious<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>k', '<cmd>tabnext<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-w>t',    '<cmd>tabnew<CR>', opts)
vim.api.nvim_set_keymap('n', '<C-w><C-q>','<cmd>tabclose<CR>', opts)
-- fast window navigation: combination <C-w> is too common to delete, ie <C-w>s for split and <C-w>r for swap
vim.api.nvim_set_keymap('n', '<A-h>',  '<C-w>h', opts)
vim.api.nvim_set_keymap('n', '<A-j>',  '<C-w>j', opts)
vim.api.nvim_set_keymap('n', '<A-k>',  '<C-w>k', opts)
vim.api.nvim_set_keymap('n', '<A-l>',  '<C-w>l', opts)
-- spell --
vim.api.nvim_set_keymap('n', '<leader>sp', [[<cmd>lua if vim.wo.spell == false then vim.wo.spell = true; else vim.wo.spell = false; end<CR>]], opts)
-- copypasta --
vim.api.nvim_set_keymap('v', '<leader>p', '"_dP', opts)
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', opts)
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', opts)
vim.api.nvim_set_keymap('n', '<leader>Y', 'gg"+yG', opts)
-- vim-fugitive --
-- TODO

-- dap debugger --
vim.api.nvim_set_keymap('n', '<leader>dh', [[<cmd>lua require'dap'.toggle_breakpoint()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<S-k>', [[<cmd>lua require'dap'.step_out()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<S-l>', [[<cmd>lua require'dap'.step_into()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<S-j>', [[<cmd>lua require'dap'.step_over()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>ds', [[<cmd>lua require'dap'.stop()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>dn', [[<cmd>lua require'dap'.continue()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>dk', [[<cmd>lua require'dap'.up()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>dj', [[<cmd>lua require'dap'.down()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>d_', [[<cmd>lua require'dap'.run_last()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>dr', [[<cmd>lua require'dap'.repl.open({}, 'vsplit')<CR><C-w>l]], opts)
vim.api.nvim_set_keymap('n', '<leader>di', [[<cmd>lua require'dap.ui.variables'.hover()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>di', [[<cmd>lua require'dap.ui.variables'.visual_hover()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>d?', [[<cmd>lua require'dap.ui.variables'.scopes()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>de', [[<cmd>lua require'dap'.set_exception_breakpoints({"all"})<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>da', [[<cmd>lua require'debugHelper'.attach()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>dA', [[<cmd>lua require'debugHelper'.attachToRemote()<CR>]], opts)
-- visual dap --
--vim.api.nvim_set_keymap('n', <leader>di, [[<cmd>lua require'dap.ui.widgets'.hover()<CR>]], opts)
--vim.api.nvim_set_keymap('n', <leader>d?, [[<cmd>lua local widgets=require'dap.ui.widgets';widgets.centered_float(widgets.scopes)<CR>]], opts)
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
vim.api.nvim_set_keymap('n', '<leader>m', [[<cmd>lua require('material.functions').toggle_style()<CR>]], opts)
-- lspsaga --
--  switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
vim.api.nvim_set_keymap('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd',    [[<cmd>lua require'lspsaga.provider'.preview_definition()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'gs',    [[<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'gh',    [[<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>]], opts) --i,o,s,
vim.api.nvim_set_keymap('n', 'gr',    [[<cmd>lua require('lspsaga.rename').rename()<CR>]], opts)
vim.api.nvim_set_keymap('n', 'K',     [[<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<C-f>', [[<cmd>lua require('lspsaga.hover').smart_scroll_hover(1)<CR>]], opts)
vim.api.nvim_set_keymap('n', '<C-b>', [[<cmd>lua require('lspsaga.hover').smart_scroll_hover(-1)<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>ca', [[<cmd>lua require('lspsaga.codeaction').code_action()<CR>]], opts)
vim.api.nvim_set_keymap('v', '<leader>ca', [[<cmd>'<,'>lua require('lspsaga.codeaction').range_code_action()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>cd', [[<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>]], opts)
vim.api.nvim_set_keymap('n', '[e',    [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>]], opts)
vim.api.nvim_set_keymap('n', ']e',    [[<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<A-t>', [[<cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>]], opts)
vim.api.nvim_set_keymap('t', '<A-t>', [[<C-\><C-n><cmd>lua require('lspsaga.floaterm').close_float_terminal()<CR>]], opts)
-- compe --
vim.api.nvim_set_keymap('i', '<C-Space>', [[compe#complete()]], { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('i', '<CR>', [[compe#confirm('<CR>')]], { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('i', '<C-e>', [[compe#close('<C-e>')]], { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('i', '<C-f>', [[compe#scroll({ 'delta': +4 })]], { noremap = true, silent = true, expr = true })
vim.api.nvim_set_keymap('i', '<C-d>', [[compe#scroll({ 'delta': -4 })]], { noremap = true, silent = true, expr = true })

-- trouble  --
vim.api.nvim_set_keymap("n", "<leader>xx", "<cmd>LspTroubleToggle<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xw", "<cmd>LspTroubleToggle lsp_workspace_diagnostics<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xd", "<cmd>LspTroubleToggle lsp_document_diagnostics<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xl", "<cmd>LspTroubleToggle loclist<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xq", "<cmd>LspTroubleToggle quickfix<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>xr", "<cmd>LspTrouble lsp_references<cr>", opts)
-- telescope --
vim.api.nvim_set_keymap('n', '<leader>tb',   [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>ff',  [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>gf',  [[<cmd>lua require('telescope.builtin').git_files()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>rg',  [[<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>]], opts) --.grep_string({ search = vim.fn.input("Grep For > ")})
vim.api.nvim_set_keymap('n', '<leader>th',   [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts)
vim.api.nvim_set_keymap('n', '<leader>pr',   [[<cmd>lua require'telescope'.extensions.project.project{}<CR>]], opts) -- d, r, c, s(in your project), w(change dir without open), f
vim.api.nvim_set_keymap('n', '<leader>z',   [[<cmd>lua require'telescope'.extensions.z.list{ cmd = { vim.o.shell, '-c', 'zoxide query -sl' } }<CR>]], opts)

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
--TODO lua setup for split creation looks broken

