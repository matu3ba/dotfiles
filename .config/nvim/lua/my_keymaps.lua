local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
-- tabs to space :%s/^\t\+/ /g
-- space to tabs :%s/^\s\+/\t/g
-- https://vi.stackexchange.com/questions/495/how-to-replace-tabs-with-spaces
-- TODO:
--        , prefix for all window operation mappings (e.g. splits, tabs, switching, file drawer etc)
--        <Space> prefix for fuzzy finding mappings (e.g. files, buffers, helptags etc)
--        ; prefix for plugin operation mappings (e.g. running tests, easy motions etc)
--        \ prefix for my find and replace helpers, \ is unmapped!
--        ' works good with left+right hand
--   Ctrl-s shell stuff
--    steal+adapt telescope keymappings:
--    https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/plugin/lsp.vim
-- TODO use C-k for killing search?
-- TODO use C-p for selecting project, ie via zoxide history
-- C-, C-. => weird keybindings. Maybe use for replace repeat, forward search?
-- C-n: [count] lines downward |linewise|.
-- C-m: [count] lines downward, on the first non-blank character |linewise|
--
-- TODO :helpgrep|Telescope help_tags and map quickfixlist cnext and cprev + getting through search history
-- C-n, C-p next,previous line, C-m newline beginning
-- C-i, C-o next previous cursor position list
-- C-d|u|y|e down|up|small up|small down|

-- enable the following once which-key fixes
--map('n', ' ', '', opts)
--map('x', ' ', '', opts)
-- remove antipatterns on qwerty keyboard layout --
map('', '<left>', '<nop>', opts)
map('', '<down>', '<nop>', opts)
map('', '<up>', '<nop>', opts)
map('', '<right>', '<nop>', opts)
-- glorious copypasta --
-- TODO search without jumping and copy connected word under cursor
-- (a.b.c and a-b-c without brackets and emptyspace) to default register
-- for pre+postfixing
--map <A-v> viw"+gPb
--map <A-c> viw"+y
--map <A-x> viw"+x
-- leader + 1 letter: common text operation
-- <l>a|b|e|i| (j|k|l)? |o|q|k|s|u|v|w|x|y
-- TODO come up with something to copy whole word under cursor, ie this.is.a.word(thisnot)
map('n', 'K', 'i<CR><ESC>', opts)
map('n', '<leader>y', '"+y', opts)
map('v', '<leader>y', '"+y', opts)
map('v', '<leader>dd', '"_dd', opts)
--map('v', '<leader>dd', '"_d', opts)
map('n', '<leader>Y', 'gg"+yG', opts) -- copy all
map('n', '<leader>P', [["_diwP]], opts) -- keep pasting over the same thing

-- replace current word/"/'/) with what is in default register
--vim.api.nvim_set_keymap('n', '<leader>w', 'viwpgvy', { noremap = true })
--vim.api.nvim_set_keymap('n', '<leader>"', 'vi"pgvy', { noremap = true })
--vim.api.nvim_set_keymap('n', "<leader>'", "vi'pgvy", { noremap = true })
--vim.api.nvim_set_keymap('n', "<leader>)", "vi)pgvy", { noremap = true })



-- color switching --
map('n', '<leader>ma', [[<cmd>lua require('material.functions').toggle_style()<CR>]], opts) -- switch material style
-- spell -- [s]s,z=,zg add to wortbook, zw remove from wordbook
map('n', '<leader>sp', [[<cmd>lua ToggleOption(vim.wo.spell)<CR>]], opts)
-- tab navigation --
map('n', '<C-w>t', '<cmd>tabnew<CR>', opts) -- next,previous,specific number gt,gT,num gt
map('n', '<C-w><C-q>', '<cmd>tabclose<CR>', opts)
-- buffer navigation --
map('n', ']b', '<cmd>bn<CR>', opts)
map('n', '[b', '<cmd>bp<CR>', opts)
-- error navigation
map('n', ']q', '<cmd>qn<CR>', opts)
map('n', '[q', '<cmd>qp<CR>', opts)
-- TODO use ]-m jump to next method for C-languages
-- ]-c used in gitsigns
-- TODO swap left alt to ctrl and c-n and c-p down and up the options

-- venn.nvim: enable or disable keymappings
_G.Toggle_venn = function()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == 'nil' then
    vim.b.venn_enabled = true
    vim.cmd [[setlocal ve=all]]
    -- draw a line on HJKL keystokes
    vim.api.nvim_buf_set_keymap(0, 'n', 'J', '<C-v>j:VBox<CR>', opts)
    vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<C-v>k:VBox<CR>', opts)
    vim.api.nvim_buf_set_keymap(0, 'n', 'L', '<C-v>l:VBox<CR>', opts)
    vim.api.nvim_buf_set_keymap(0, 'n', 'H', '<C-v>h:VBox<CR>', opts)
    -- draw a box by pressing "f" with visual selection
    vim.api.nvim_buf_set_keymap(0, 'v', 'f', ':VBox<CR>', opts)
  else
    vim.cmd [[setlocal ve=]]
    vim.cmd [[mapclear <buffer>]]
    vim.b.venn_enabled = nil
  end
end
vim.api.nvim_set_keymap('n', '<leader>v', ':lua Toggle_venn()<CR>', opts)

-- session navigation <A-1> etc for switch session
-- how can I list sessions?
-- window navigation: <C-w>[+|-|<|>|_|"|"|=|s|v|r| height,width,height,width,equalise,split,swap
-- view movements: z+b|z|t, <C>+y|e (one line), ud (halfpage), bf (page, cursor to last line)
-- vim-surround: TODO
-- vim-easy-align TODO
-- +/n/* goto beginning of next line/next instance of search/next instance of word under cursor
-- :set nowrapscan => error out on end of file
-- :set lazyredraw => skip until commands are finished
-- g; and g, for cursor editing position history, ''|`` for cursor position history
-- :g for actions on regex match
-- K for move text to next line

-- insertion mode
-- C-r insert from register, TODO stuff to run commands in between
-- navigation from within insertion mode

-- cmdline
-- C-z trigger wildmode, C-] abbreviations
-- C-d|n|p|a|l manual completions TODO explain
-- :his, C-g|C-t search

---- dap debugger ----
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
--nnoremap <leader>df :Telescope dap frames<CR>
--nnoremap <leader>dc :Telescope dap commands<CR>
--nnoremap <leader>db :Telescope dap list_breakpoints<CR>

---- lspconfig ----
-- switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
map('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts) -- switch header_source
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts) -- **g**oto definition
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts) -- **g**oto signature
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts) -- **g**oto rename
map('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- next error
map('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts) -- previous error
map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts) -- code action
map('n', '<leader>cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts) -- line diagnostics
map('n', '<leader>rf', '<cmd>lua vim.lsp.buf.references()<CR>', opts) -- references
map('n', '<leader>ql', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts) -- references
map('n', '<leader>fo', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts) -- references
--map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts) -- Kimme_info
--map('n', 'gDD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)   -- gt, gT used for tabnext
--map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts) -- conflicting
--map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- exploring code base with mouse TODO mouse mapping 1. to close and 2. to navigate
--map('n', '<LeftMouse>', '<LeftMouse><cmd>lua vim.lsp.buf.hover({border = "single"})<CR>', opts)
--map('n', '<RightMouse>', '<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>', opts)
---- telescope ---- fuzzy_match 'extact_match ^prefix-exact suffix_exact$ !inverse_match, C-x split,C-v vsplit,C-t new tab
-- C-q (send to quickfixlist), :cdo %s/<search term>/<replace term>/gc, :cdo update (saving)
map('n', '<leader>tb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts) -- buffers
map('n', '<leader>ts', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts) -- buffer: document symbols
map('n', '<leader>tS', [[<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>]], opts) -- workspace symbols (bigger)
map('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts) -- find files
map('n', '<leader>gf', [[<cmd>lua require('telescope.builtin').git_files()<CR>]], opts) -- git files
--.grep_string({ search = vim.fn.input("Grep For > ")})
map(
  'n',
  '<leader>rg',
  [[<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>]],
  opts
) -- ripgrep string
map('n', '<leader>th', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts) -- helptags
-- <C-p> for projects ?
map('n', '<leader>pr', [[<cmd>lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>]], opts) -- project: d, r, c, s(in your project), w(change dir without open), f
--map('n', '<leader>z', [[<cmd>lua require'telescope'.extensions.z.list{ cmd = { vim.o.shell, '-c', 'zoxide query -sl' } }<CR>]], opts) -- zoxide
--lsp_workspace_diagnostics
--lsp_document_diagnostics
--loclist
--quickfix
--lsp_references
--map('n', '<leader>ed', [[<cmd>lua require'telescope'.extensions.project-scripts.edit{}<CR>]], opts)  -- edit_script
--map('n', '<leader>ex', [[<cmd>lua require'telescope'.extensions.project-scripts.run{}<CR>]], opts)   -- run_script

---- harpoon ---- buffer navigation
-- NOTE: terminal used as nav_file breaks after quit and navigating to it: https://github.com/ThePrimeagen/harpoon/issues/140
map('n', '<leader>j',   [[<cmd>lua require("harpoon.ui").nav_file(1)<CR>]], opts) -- bare means fast navigate
map('n', '<leader>k',   [[<cmd>lua require("harpoon.ui").nav_file(2)<CR>]], opts)
map('n', '<leader>l',   [[<cmd>lua require("harpoon.ui").nav_file(3)<CR>]], opts)
map('n', '<leader>u',   [[<cmd>lua require("harpoon.ui").nav_file(4)<CR>]], opts)
map('n', '<leader>i',   [[<cmd>lua require("harpoon.ui").nav_file(5)<CR>]], opts)
map('n', '<leader>o',   [[<cmd>lua require("harpoon.ui").nav_file(6)<CR>]], opts)
map('n', '<leader>mj',  [[<cmd>lua require("harpoon.mark").set_current_at(1)<CR>]], opts) --m means make to 1
map('n', '<leader>mk',  [[<cmd>lua require("harpoon.mark").set_current_at(2)<CR>]], opts)
map('n', '<leader>ml',  [[<cmd>lua require("harpoon.mark").set_current_at(3)<CR>]], opts)
map('n', '<leader>mu',  [[<cmd>lua require("harpoon.mark").set_current_at(4)<CR>]], opts)
map('n', '<leader>mi',  [[<cmd>lua require("harpoon.mark").set_current_at(5)<CR>]], opts)
map('n', '<leader>mo',  [[<cmd>lua require("harpoon.mark").set_current_at(6)<CR>]], opts)
map('n', '<leader>mrj', [[<cmd>lua require("harpoon.mark").rm_file(1)<CR>]], opts) -- mrj for removing first file
map('n', '<leader>mrk', [[<cmd>lua require("harpoon.mark").rm_file(2)<CR>]], opts)
map('n', '<leader>mrl', [[<cmd>lua require("harpoon.mark").rm_file(3)<CR>]], opts)
map('n', '<leader>cj',  [[<cmd>lua require("harpoon.term").gotoTerminal(1)<CR>]], opts) -- c means terminal
map('n', '<leader>ck',  [[<cmd>lua require("harpoon.term").gotoTerminal(2)<CR>]], opts)
map('n', '<leader>cl',  [[<cmd>lua require("harpoon.term").gotoTerminal(3)<CR>]], opts)
map('n', '<leader>mv',  [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>]], opts) -- mv for move to overview
map('n', '<leader>mm',  [[<cmd>lua require("harpoon.mark").add_file()<CR>]], opts) -- mm means fast adding files to belly
map('n', '<leader>mc',  [[<cmd>lua require("harpoon.mark").clear_all()<CR>]], opts) -- mc means fast puking away files

---- nnn ----
map('n', '<leader>n', [[<cmd> NnnExplorer<CR>]], opts) -- file exlorer
--map('t', '<leader>n',   [[<cmd> NnnExplorer<CR>]], opts) -- file exlorer
map('n', '<leader>pi', [[<cmd> NnnPicker<CR>]], opts) -- file exlorer
--map('t', '<leader>pi',   [[<cmd> NnnPicker<CR>]], opts) -- file exlorer

---- gtest ----
map('n', ']t', [[<cmd>GTestNext<CR>]], opts)
map('n', '[t', [[<cmd>GTestPrev<CR>]], opts)
--map('t', '<leader>tu', [[<cmd>GTestRunUnderCursor<CR>]], opts) -- lightspeed breaks this binding
--map('n', '<leader>tt', [[<cmd>GTestRun<CR>]], opts) -- lightspeed breaks this binding
