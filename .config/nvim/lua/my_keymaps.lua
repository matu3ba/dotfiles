local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
-- tabs to space :%s/^\t\+/ /g
-- space to tabs :%s/^\s\+/\t/g
-- https://vi.stackexchange.com/questions/495/how-to-replace-tabs-with-spaces
-- Principle:
--  look for better prefix than , for window navigation, tab nvagiation mappings (splits, tabs, switching, file drawer etc)
--  <Space> general mapleader for fast operations
--  TODO figure out where to put fuzzy finding mappings (e.g. files, buffers, helptags etc)
--  ;       runnig tests and special commands
--  \       find and replace helpers
--  _       unmapped
--  -       unmapped
--  TODO conflicting keybinding: YSurround yS, ys
--  TODO conflicting keybinding: comment_toggle_blocks/linewise gb,gc
--  <C-s>   shell stuff
-- TODO use C-, C-. for something: Maybe use for replace repeat, forward search?

-- C-n: [count] lines downward |linewise|.
-- C-m: [count] lines downward, on the first non-blank character |linewise|
-- :helpgrep|Telescope help_tags and map quickfixlist cnext and cprev + getting through search history
-- C-n, C-p next,previous line, C-m newline beginning
-- C-i, C-o next previous cursor position list
-- C-d|u|y|e down|up|small up|small down|
--https://www.hillelwayne.com/post/intermediate-vim/

-- enable the following once which-key fixes
--map('n', ' ', '', opts)
--map('x', ' ', '', opts)
-- remove antipatterns on qwerty keyboard layout --
--map('', '<left>', '<nop>', opts)
--map('', '<down>', '<nop>', opts)
--map('', '<up>', '<nop>', opts)
--map('', '<right>', '<nop>', opts)
-- glorious copypasta --
-- (a.b.c and a-b-c without brackets and emptyspace) to default register for pre+postfixing
-- idea list used function scopes of variable under cursor, needs clarification
--map <A-v> viw"+gPb
--map <A-c> viw"+y
--map <A-x> viw"+x
-- leader + 1 letter: common text operation
-- <l>a|b|e|i| (j|k|l)? |o|q|k|s|u|v|w|x|y
-- alternative mapping: 1. * without jumping, 2. cgn (change go next match), 3. n 4. . (repeat action)
-- current mapping requires 1. viwy, 2. * with jumping, 3. , (with mapping to keep pasting over)
map('n', '<C-s><C-s>', [[<cmd>w<CR>]], opts) -- fast saving of local file
-- map('n', '>l', [[<cmd>cnext<CR>]], opts) -- next quickfix list item
-- map('n', '>h', [[<cmd>cprev<CR>]], opts) -- previous quickfix list item
map('n', ',', [["_diwP]], opts) -- keep pasting over the same thing, old map: C-p
map('n', '*', [[m`:keepjumps normal! *``<CR>]], opts) -- word boundary search, no autojump
map('n', 'g*', [[m`:keepjumps normal! g*``<CR>]], opts) -- no word boundary search no autojump
--map('n', '/', [[:setl hls | let @/ = input('/')<CR>]], opts) -- no incsearch on typing
map('v', '//', [[y/\V<C-R>=escape(@",'/\')<CR><CR>]], opts) -- search selected region on current line
-- idea |copy_history:| keypress to extract search properly from history without \V
--map('n', '<C-j>', '<ESC>', opts) -- better escape binding.
map('n', 'B', 'i<CR><ESC>', opts) -- J(join) B(BackJoin): move text after cursor to next line
-- idea parse current line until no ending \ inside register instead of blindly executing
--map('n', '<leader>e', [[:exe getline(line('.'))<CR>]], opts) -- Run the current line as if it were a command
--nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
--nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
--nnoremap <leader>e :exe getline(line('.'))<cr> -- Run the current line as if it were a command
-- idea come up with something to select whole word under cursor, ie this.is.a.word(thisnot)

--- Copy content to matching char into register
-- without match, a message is printed
-- @param backwards boolean if search is forwards or backwards
-- @param register register where content is copied to
_G.CopyMatchingChar = function(backwards, register)
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local crow = tup_rowcol[1]
  local ccol = tup_rowcol[2] -- 0 indexed => use +1
  local cchar = vim.api.nvim_get_current_line():sub(ccol + 1, ccol + 1)
  local matchchar = {
    ['('] = ')',
    [')'] = '(',
    ['{'] = '}',
    ['}'] = '{',
    ['['] = ']',
    [']'] = '[',
    ['<'] = '>',
    ['>'] = '<',
    ['"'] = '"',
    ["'"] = "'",
    ['|'] = '|',
    ['`'] = '`',
    ['/'] = '/',
    ['\\'] = '\\',
  }
  -- TODO searchpos: stopline only works forwards
  -- => flag 'b' is not using starting line
  local tup_search
  if backwards == false then
    tup_search = vim.fn.searchpos(matchchar[cchar], 'nz', crow + 1) -- +1 to search until next line?
  else
    tup_search = vim.fn.searchpos(matchchar[cchar], 'bnz') -- +1 to search until next line?
  end
  local srow = tup_search[1]
  local scol = tup_search[2]
  if srow == 0 and scol == 0 and backwards == false then
    print 'no matching forward character'
    return
  end
  if (srow == 0 and scol == 0 and backwards == true) or srow ~= crow or (backwards == true and ccol < scol) then
    print 'no matching backwards character'
    return
  end
  local copytext
  if backwards == false then
    copytext = vim.api.nvim_get_current_line():sub(ccol + 1, scol)
    print(string.format([[%s %s:%s]], [[write -> into]], register, copytext))
  else
    copytext = vim.api.nvim_get_current_line():sub(scol, ccol + 1)
    print(string.format([[%s %s:%s]], [[write <- into]], register, copytext))
  end
  vim.fn.setreg(register, copytext)
end

--SAME LINE SELECTION AND COPY MOVEMENTS--
--TODO clarify if there is a cursor move api for lua ie for selecting
--TODO select forward + backwards
--TODO copy forward + backwards, if only 1 possible match on same line
--for "",'',``,(),{},[]
---- copy forward/backwards until first occurence of same symbol
map('n', '-', ':lua CopyMatchingChar(false, [[""]])<CR>', opts)
map('n', '_', ':lua CopyMatchingChar(true, [[""]])<CR>', opts)

map('n', '<leader>qq', ':q<CR>', opts) -- faster, but no accidental quit
map('n', '<leader>q!', ':q!<CR>', opts) -- faster, but no accidental quit
map('n', '<leader>qb', ':bd<CR>', opts) -- faster, but no accidental quit
--map('n', '<leader>y', '"+y', opts) -- used default
--map('v', '<leader>y', '"+y', opts) -- used default
map('v', '<leader>D', '"_D', opts) -- delete into blackhole register
--map('v', '<leader>d', '"_d', opts) -- stuff, TODO conflicting keybinding
map('v', '<leader>dd', '"_dd', opts) -- TODO dont walk 1 line down from eol
-- note: vimscript can not handle marks in between commands
map('n', '<leader>p', [[mm"_Dp`m]], opts) -- keep pasting over the same thing, old map: C-p
map('n', '<leader>Y', 'gg"+yG', opts) -- copy all
-- C-w delete word, C-y paste word, C-p,C-n,C-i complete path
-- C-h delete last character,
-- A-o and A-h are used to switch to visual mode, where ^ and $ work to jump etc
-- visualmode: f is file lookup, v opens command for copying (also executes!)
-- C-a,C-f,C-g,C-k,C-l,C-v,C-b free in emacs mode
map('t', '<C-q>', [[<C-\><C-n>]], opts) -- quit terminal editing
map('t', '<C-a>', [[<C-\><C-n><C-w>]], opts) -- quitAnd.. (enter windowing in hydra)

-- pasting without moving cursor: p`[       <<<--- without ]

-- write path into variable user_cwd
-- keybinding to cd terminal to user_cwd
-- replace current word/"/'/) with what is in default register
--vim.api.nvim_set_keymap('n', '<leader>w', 'viwpgvy', { noremap = true })
--vim.api.nvim_set_keymap('n', '<leader>"', 'vi"pgvy', { noremap = true })
--vim.api.nvim_set_keymap('n', "<leader>'", "vi'pgvy", { noremap = true })
--vim.api.nvim_set_keymap('n', "<leader>)", "vi)pgvy", { noremap = true })

-- color switching --
map('n', '<leader>ma', [[<cmd>lua require('material.functions').toggle_style()<CR>]], opts) -- switch material style
---- spell ---- [s]s,z=,zg add to wortbook, zw remove from wordbook
--map('n', '<leader>sp', [[<cmd>lua ToggleOption(vim.wo.spell)<CR>]], opts)
---- tab navigation ----
map('n', '<C-w>t', '<cmd>tabnew<CR>', opts) -- next,previous,specific number gt,gT,num gt
map('n', '<C-w><C-q>', '<cmd>tabclose<CR>', opts)
-- next,previous,specific number gt,gT,num gt
-- TODO prefix for left hand to keep hjl for navigation
--map('n', ',t', '<cmd>tabnew<CR>', opts) -- Newtab (like in browser)
--map('n', ',w', '<cmd>tabclose<CR>', opts) -- Closetab (like in browser)
---- window navigation ----
-- see my_hydra.lua
--map('n', ';S', '<cmd>Sexplore<CR>', opts) -- Sexplore
--map('n', ';V', '<cmd>Vexplore<CR>', opts) -- Vexplore
--map('n', ';E', '<cmd>Explore<CR>', opts) -- Explore
---- buffer navigation ----
--map('n', ']b', '<cmd>bn<CR>', opts)
--map('n', '[b', '<cmd>bp<CR>', opts)
--map('n', ';l', '<cmd>ls<CR>', opts) -- list buffers
--map('n', ';e', '<cmd>bn<CR>', opts) -- previous buffer
--map('n', ';y', '<cmd>bp<CR>', opts) -- next buffer
--map('n', ';b', '<cmd>ls<CR>', opts) -- list buffers
--nnoremap <expr> <C-b> v:count ? ':<c-u>'.v:count.'buffer<cr>' : ':set nomore<bar>ls<bar>set more<cr>:buffer<space>'
--:bdel for buffer deletion
--TODO think how to pick buffer quick: ideally fuzzy search matches in telescope to add them
--Then assign quickjump mappings in the picker.
--Store everything in a session file.
--TODO think how to delete buffers quick
---- error navigation ----
map('n', ']q', '<cmd>qn<CR>', opts)
map('n', '[q', '<cmd>qp<CR>', opts)
---- shell navigation ----
map('n', '\\st', [[/@.*@.*:<CR>]], opts) -- search terminal (for command prompt)
map('n', '\\sw', [[/WEXEC<CR>]], opts) -- search for WEXEC (watchexec) in terminal output
-- use ]-m jump to next method for C-languages
-- swap left alt to ctrl and c-n and c-p down and up the options

-- venn.nvim: enable or disable keymappings
-- _G.Toggle_venn = function()
--   local venn_enabled = vim.inspect(vim.b.venn_enabled)
--   if venn_enabled == 'nil' then
--     vim.b.venn_enabled = true
--     vim.cmd [[setlocal ve=all]]
--     -- draw a line on HJKL keystokes
--     vim.api.nvim_buf_set_keymap(0, 'n', 'J', '<C-v>j:VBox<CR>', opts)
--     vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<C-v>k:VBox<CR>', opts)
--     vim.api.nvim_buf_set_keymap(0, 'n', 'L', '<C-v>l:VBox<CR>', opts)
--     vim.api.nvim_buf_set_keymap(0, 'n', 'H', '<C-v>h:VBox<CR>', opts)
--     -- draw a box by pressing "f" with visual selection
--     vim.api.nvim_buf_set_keymap(0, 'v', 'f', ':VBox<CR>', opts)
--   else
--     vim.cmd [[setlocal ve=]]
--     vim.cmd [[mapclear <buffer>]]
--     vim.b.venn_enabled = nil
--   end
-- end
-- vim.api.nvim_set_keymap('n', '<leader>v', ':lua Toggle_venn()<CR>', opts)

-- visual mode hidden
-- continue (aborted) search: A-n

-- visual mode regular
-- window navigation: <C-w>[+|-|<|>|"|=|s|v|r| and _| height,width,height,width,equalise,split,swap max size horizontal/vertical
-- view movements up+down: z+b|z|t, <C>+y|e (one line), ud (halfpage), bf (page, cursor to last line)
-- more aracane: z+,z-,z. like zt,zb,zz
-- view movements left+righ: z+es(full page), hl(1char), HL(halfpage)
-- vim-surround: ds|cs|ys,yS etc is conflicting
-- vim-easy-align TODO
-- +/n/* goto beginning of next line/next instance of search/next instance of word under cursor
-- C-t jumps back to the beginning of file entering from goto definition
-- :set nowrapscan => error out on end of file
-- g; and g, for cursor editing position history, ''|`` for cursor position history
-- :g for actions on regex match
-- /regex/n nth line below/above match, d/regex//0 to delete to first line matching regex incl line
-- regex matches: \r for newline and \n for null character, except in search lol
-- K for move text to next line
-- C-r C-w insert word under cursor
-- ":, @: reruns last command :"p would print it to the buffer, :! for output

-- insertion mode
-- C-w delete last word, C-u delete until start of line
-- C-o execute 1 command and continue in insertion mode (go to normal mode for 1 key action)
-- C-h switch back to normal mode(side effect from coq_nvim, C-r insert from register,
-- quick setttings
-- :set rnu!   to toggle relative numbers
-- :set spell!   to toggle spelling

-- cmdline
-- C-z trigger wildmode, C-] abbreviations

---- insert completion ----
-- :h i_CTRL-X_CTRL-D
-- C-n|p complete what is in all buffers
-- <C-x><C-n|p> complete from current buffer
-- <C-x><C-d> .. <C-n|p> complete macros
-- <C-x><C-f> .. <C-n|p> complete file paths
-- <C-x><C-i> .. <C-n|p> complete include paths
-- <C-x><C-k> .. <C-n|p> complete keyword in dictionary
-- <C-x><C-l> .. <C-n|p> complete entire lines
-- <C-x><C-o> .. <C-n|p> complete user defined function given as omnifunc
-- <C-x><C-s> .. <C-n|p> complete spelling suggestions
-- <C-x><C-t> .. <C-n|p> complete thesaurus
-- <C-x><C-u> .. <C-n|p> complete user defined function given as completefunc
-- <C-x><C-v> .. <C-n|p> complete vim commands
-- <C-x><C-z> stop completion
-- <C-x><C-]> .. <C-n|p> complete words starting at tag

-- <C-@> insert previously inserted text and stop insert
-- <C-a> insert previously inserted text
-- <C-h> delete character before cursor                => faster than backspace
-- <del> delete character under cursor              => no different, but slower
-- <C-w> delete word before cursor
-- <C-u> delete all entered character before cursor from current line
-- <C-j> begin new line = <NL>
-- <C-m> begin new line = <CR>
-- <C-o> stop insertion for 1 action
-- <C-r> insert content from register as if it would be typed by user
-- <C-r><C-r> liteel insertion of content from register
-- <C-r><C-r> same as <C-r><C-r>, but without autoindent
-- ..
-- <C-x> ctrl-x mode
-- insert char below and above cursor with <C-e> and <C-y>
-- <C-]> trigger abbreviations without inserting character

-- :his, C-g|C-t search
-- last inserted text is in . register to be used with ".p
-- It should be possible from insertion mode to paste with C-a
-- C-d|n|p|a|l manual completions TODO explain
-- C-n,C-p to complete from all buffers
-- C-x C-n to complete from current buffer
-- :his, C-g|C-t search

-- selection mode
-- word selected + K => search manual entry

---- dap debugger ----
--map('n', '<leader>db', [[<cmd>lua require'dap'.toggle_breakpoint()<CR>]], opts)
--map('n', '<A-k>', [[<cmd>lua require'dap'.step_out()<CR>]], opts)
--map('n', '<A-l>', [[<cmd>lua require'dap'.step_into()<CR>]], opts)
--map('n', '<A-j>', [[<cmd>lua require'dap'.step_over()<CR>]], opts)
--map('n', '<leader>ds', [[<cmd>lua require'dap'.stop()<CR>]], opts)
--map('n', '<leader>dc', [[<cmd>lua require'dap'.continue()<CR>]], opts)
--map('n', '<leader>dk', [[<cmd>lua require'dap'.up()<CR>]], opts)
--map('n', '<leader>dj', [[<cmd>lua require'dap'.down()<CR>]], opts)
--map('n', '<leader>d_', [[<cmd>lua require'dap'.run_last()<CR>]], opts)
--map('n', '<leader>dr', [[<cmd>lua require'dap'.repl.open({}, 'vsplit')<CR><C-w>l]], opts)
--map('n', '<leader>di', [[<cmd>lua require'dap.ui.variables'.hover()<CR>]], opts)
--map('n', '<leader>dvi', [[<cmd>lua require'dap.ui.variables'.visual_hover()<CR>]], opts)
--map('n', '<leader>d?', [[<cmd>lua require'dap.ui.variables'.scopes()<CR>]], opts)
--map('n', '<leader>de', [[<cmd>lua require'dap'.set_exception_breakpoints({"all"})<CR>]], opts)
--map('n', '<leader>da', [[<cmd>lua require'debugHelper'.attach()<CR>]], opts)
--map('n', '<leader>dA', [[<cmd>lua require'debugHelper'.attachToRemote()<CR>]], opts)
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
--map('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts) -- **g**oto signature
map('n', 'gr', '<cmd>lua vim.lsp.buf.rename()<CR>', opts) -- **g**oto rename
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts) -- Kuckstu definition
map('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts) -- next error
map('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts) -- previous error
map('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts) -- code action
map('n', '<leader>cd', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts) -- line diagnostics
map('n', '<leader>rf', '<cmd>lua vim.lsp.buf.references()<CR>', opts) -- references
map('n', '<leader>ql', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts) -- buffer diagnostics to location list
map('n', '<leader>qf', '<cmd>lua vim.diagnostic.setqflist()<CR>', opts) -- all diagnostics to quickfix list
map('n', '<leader>fo', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts) -- references
map('n', '<leader>re', '<cmd>LspRestart<CR>', opts) -- restart lsp

---- ctags ----
-- switch between source and header with `:e %<.c` with %< representing the current file without the ending
-- :tag file.c, :tags for overview (or selection on multiple matches)
-- C-] to go to tag definition, C-t to jump back
-- :ts/:tselect definitions for last tag
--- Switch between header and source file.
-- Header is identified with .h, source file with precedense .cpp, .cc.
-- TODO: figure out how to call vimscript commands without global variables
--_G.SwitchHeaderSourceTags = function()
--  filename = vim.fn.expand '%'
--  vim.api.nvim_exec(
--  [[
--  let l:origfname = expand('%')
--  "let l:filenamenoext = expand('%:t:r')
--  "let l:fname = ''
--  "if expand('%:e') ==# 'h' then
--  "  let l:fname = l:filenamenoext . '.cpp'
--  "  exec 'tag ' . l:fname
--  "  if l:origfname !=# expand('%') then
--  "    return
--  "  else
--  "    let l:fname = l:filenamenoext . '.cc'
--  "    exec 'tag ' . l:fname
--  "  endif
--  "else
--  "  let l:fname = l:filenamenoext . '.h'
--  "  exec 'tag ' . l:fname
--  "endif
--  ]],
--  false)
--  --local filename_noext = vim.fn.expand '%:t:r'
--  --if (vim.fn.expand '%:e' == 'h') then
--  --  local cppname = filename_noext .. ".cpp"
--  --  -- fallback: exe 'tag '.tag_name
--  --  -- TODO: solve this with git ls-files and regex match
--  --  vim.fn.tag(cppname)
--  --  if (filename ~= vim.fn.expand('%')) then
--  --    return
--  --  else
--  --    local ccname = filename_noext .. ".cpp"
--  --    vim.fn.tag(cppname)
--  --  end
--  --else
--  --  local hname = filename_noext .. ".h"
--  --  vim.fn.tag(cppname)
--  --end
--end
--map('n', '<leader>st', ':lua SwitchHeaderSourceTags()<CR>', opts)

---- coq autocompleter ----
-- default bindings. C-h next snippet, C-w|u deletion of word, C-k preview
--let g:coq_settings = {
--      \ 'auto_start': v:true,
--      \ 'display.icons.mode': 'none',
--      \ 'keymap.recommended': v:false,
--      \ 'keymap.manual_complete': '<C-Space>',
--      \ 'keymap.jump_to_mark': '<C-j>',
--      \ 'keymap.bigger_preview': '<C-k>',
--      \ }

--map('n', 'gDD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)   -- gt, gT used for tabnext
--map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts) -- conflicting
--map('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
--map('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
--map('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
--map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--map('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
-- exploring code base with mouse mapping 1. to close and 2. to navigate
--map('n', '<LeftMouse>', '<LeftMouse><cmd>lua vim.lsp.buf.hover({border = "single"})<CR>', opts)
--map('n', '<RightMouse>', '<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>', opts)

---- telescope ---- fuzzy_match 'extact_match ^prefix-exact suffix_exact$ !inverse_match, C-x split,C-v vsplit,C-t new tab
-- vimgrep AA also sends into a quickfix
-- C-q (send to quickfixlist), :cdo %s/<search term>/<replace term>/gc, :cdo update (saving)
-- :norm {Vim} run command on every line
-- shift|shift+tab selects items
map('n', '<leader>tb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], opts) -- buffers
map('n', '<leader>ts', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts) -- buffer: document symbols
map('n', '<leader>tk', [[<cmd>lua require('telescope.builtin').keymaps()<CR>]], opts) -- keybindings
-- builtin.commands, nmap, vmap, imap
map('n', '<leader>tS', [[<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>]], opts) -- workspace symbols (bigger)
map('n', '<leader>ff', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], opts) -- find files
map('n', '<leader>gf', [[<cmd>lua require('telescope.builtin').git_files()<CR>]], opts) -- git files
map('n', '<leader>sp', [[<cmd>lua require'telescope'.extensions.project.project{}<CR>]], opts) -- search project

--.grep_string({ search = vim.fn.input("Grep For > ")})
map(
  'n',
  '<leader>rg',
  [[<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.expand("<cword>") }<CR>]],
  opts
) -- ripgrep string
map(
  'n',
  '<leader>ss',
  [[<cmd>lua require('telescope.builtin').grep_string { search = vim.fn.input("grep:")}<CR>]],
  opts
) -- search string
map('n', '<leader>th', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], opts) -- helptags
-- <C-p> for projects ?
--map('n', '<leader>pr', [[<cmd>lua require'telescope'.extensions.project.project{display_type = 'full'}<CR>]], opts) -- project: d, r, c, s(in your project), w(change dir without open), f
--map('n', '<leader>z', [[<cmd>lua require'telescope'.extensions.z.list{ cmd = { vim.o.shell, '-c', 'zoxide query -sl' } }<CR>]], opts) -- zoxide
--lsp_workspace_diagnostics
--lsp_document_diagnostics
--loclist
--quickfix
--lsp_references
--map('n', '<leader>ed', [[<cmd>lua require'telescope'.extensions.project-scripts.edit{}<CR>]], opts)  -- edit_script
--map('n', '<leader>ex', [[<cmd>lua require'telescope'.extensions.project-scripts.run{}<CR>]], opts)   -- run_script

---- leap ----
map('n', '-', '<Plug>(leap-forward)', {}) -- -> forward
map('n', '_', '<Plug>(leap-backward)', {}) -- _> inverse forward
map('n', 'gs', '<Plug>(leap-cross-window)', {}) -- search and go across the windows

---- gitsigns ---- in file git operations (:Gitsigns debug_messages)
-- mappings are workaround of https://github.com/lewis6991/gitsigns.nvim/issues/498
--map('n', ']c', '<cmd>Gitsigns next_hunk<CR>', opts)
--map('n', '[c', '<cmd>Gitsigns prev_hunk<CR>', opts)
--map('n', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', opts)
--map('v', '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', opts)
--map('n', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', opts)
--map('v', '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', opts)
--map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', opts)
--map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>', opts)
--map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', opts)
--map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>', opts)
--map('n', '<leader>hb', '<cmd>Gitsigns blame_line<CR>', opts)
--map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>', opts)
--map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>', opts)
--map('n', '<leader>hD', '<cmd>Gitsigns diffthis "~"<CR>', opts)
--map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>', opts)

---- harpoon ---- buffer navigation
-- NOTE: terminal used as nav_file breaks after quit and navigating to it: https://github.com/ThePrimeagen/harpoon/issues/140
map('n', '<leader>j', [[<cmd>lua require("harpoon.ui").nav_file(1)<CR>]], opts) -- bare means fast navigate
map('n', '<leader>k', [[<cmd>lua require("harpoon.ui").nav_file(2)<CR>]], opts)
map('n', '<leader>l', [[<cmd>lua require("harpoon.ui").nav_file(3)<CR>]], opts)
map('n', '<leader>u', [[<cmd>lua require("harpoon.ui").nav_file(4)<CR>]], opts)
map('n', '<leader>i', [[<cmd>lua require("harpoon.ui").nav_file(5)<CR>]], opts)
map('n', '<leader>o', [[<cmd>lua require("harpoon.ui").nav_file(6)<CR>]], opts)
map('n', '<leader>mj', [[<cmd>lua require("harpoon.mark").set_current_at(1)<CR>]], opts) --m means make to 1
map('n', '<leader>mk', [[<cmd>lua require("harpoon.mark").set_current_at(2)<CR>]], opts)
map('n', '<leader>ml', [[<cmd>lua require("harpoon.mark").set_current_at(3)<CR>]], opts)
map('n', '<leader>mu', [[<cmd>lua require("harpoon.mark").set_current_at(4)<CR>]], opts)
map('n', '<leader>mi', [[<cmd>lua require("harpoon.mark").set_current_at(5)<CR>]], opts)
map('n', '<leader>mo', [[<cmd>lua require("harpoon.mark").set_current_at(6)<CR>]], opts)
map('n', '<leader>cj', [[<cmd>lua require("harpoon.term").gotoTerminal(1)<CR>]], opts) -- c means goto control terminal
map('n', '<leader>ck', [[<cmd>lua require("harpoon.term").gotoTerminal(2)<CR>]], opts)
map('n', '<leader>cl', [[<cmd>lua require("harpoon.term").gotoTerminal(3)<CR>]], opts)
map('n', '<leader>cu', [[<cmd>lua require("harpoon.term").gotoTerminal(4)<CR>]], opts)
map('n', '<leader>ci', [[<cmd>lua require("harpoon.term").gotoTerminal(5)<CR>]], opts)
map('n', '<leader>co', [[<cmd>lua require("harpoon.term").gotoTerminal(6)<CR>]], opts)
-- ; as prefix for runners

-- TODO: show number of terminal

-- lua has \ddd as decimal string escapes
-- send enter to each terminal
map('n', ';ej', [[<cmd>lua require("harpoon.term").sendCommand(1, "\n")<CR>]], opts) -- e means send enter
map('n', ';ek', [[<cmd>lua require("harpoon.term").sendCommand(2, "\n")<CR>]], opts)
map('n', ';el', [[<cmd>lua require("harpoon.term").sendCommand(3, "\n")<CR>]], opts)
map('n', ';eu', [[<cmd>lua require("harpoon.term").sendCommand(4, "\n")<CR>]], opts)
map('n', ';ei', [[<cmd>lua require("harpoon.term").sendCommand(5, "\n")<CR>]], opts)
map('n', ';eo', [[<cmd>lua require("harpoon.term").sendCommand(6, "\n")<CR>]], opts)

-- repeat last command
map('n', ';rj', [[<cmd>lua require("harpoon.term").sendCommand(1, "!!\n")<CR>]], opts) -- r for repeat
map('n', ';rk', [[<cmd>lua require("harpoon.term").sendCommand(2, "!!\n")<CR>]], opts)
map('n', ';rl', [[<cmd>lua require("harpoon.term").sendCommand(3, "!!\n")<CR>]], opts)
map('n', ';ru', [[<cmd>lua require("harpoon.term").sendCommand(4, "!!\n")<CR>]], opts)
map('n', ';ri', [[<cmd>lua require("harpoon.term").sendCommand(5, "!!\n")<CR>]], opts)
map('n', ';ro', [[<cmd>lua require("harpoon.term").sendCommand(6, "!!\n")<CR>]], opts)

-- send strings from register as command + execute it
map('n', '<C-s>j', [[<cmd>lua require("harpoon.term").sendCommand(1, vim.fn.getreg('j') .. "\n")<CR>]], opts) -- C-s for control send to
map('n', '<C-s>k', [[<cmd>lua require("harpoon.term").sendCommand(1, vim.fn.getreg('k') .. "\n")<CR>]], opts)
map('n', '<C-s>l', [[<cmd>lua require("harpoon.term").sendCommand(1, vim.fn.getreg('l') .. "\n")<CR>]], opts)
map('n', '<C-s>u', [[<cmd>lua require("harpoon.term").sendCommand(2, vim.fn.getreg('u') .. "\n")<CR>]], opts)
map('n', '<C-s>i', [[<cmd>lua require("harpoon.term").sendCommand(2, vim.fn.getreg('i') .. "\n")<CR>]], opts)
map('n', '<C-s>o', [[<cmd>lua require("harpoon.term").sendCommand(2, vim.fn.getreg('o') .. "\n")<CR>]], opts)

-- navigation from terminal (insertion mode) t and "normal terminal" nt
map('t', '<C-f>j', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(1)<CR>]], opts) -- file harpoon
map('t', '<C-f>k', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(2)<CR>]], opts)
map('t', '<C-f>l', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(3)<CR>]], opts)
map('t', '<C-f>u', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(4)<CR>]], opts)
map('t', '<C-f>i', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(5)<CR>]], opts)
map('t', '<C-f>o', [[<C-\><C-n><cmd>lua require("harpoon.ui").nav_file(6)<CR>]], opts)
map('t', '<C-x>j', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(1)<CR>]], opts) -- x terminal harpoon
map('t', '<C-x>k', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(2)<CR>]], opts)
map('t', '<C-x>l', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(3)<CR>]], opts)
map('t', '<C-x>u', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(4)<CR>]], opts)
map('t', '<C-x>i', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(5)<CR>]], opts)
map('t', '<C-x>o', [[<C-\><C-n><cmd>lua require("harpoon.term").gotoTerminal(6)<CR>]], opts)

-- TODO we additionally match against the minor mode here
-- vim.api.nvim_get_mode().mode: first char is major mode, second (if existing) minor mode
-- map('nt', '<C-x>j', [[<cmd>lua require("harpoon.term").gotoTerminal(1)<CR>]], opts) -- x terminal harpoon
-- map('nt', '<C-x>k', [[<cmd>lua require("harpoon.term").gotoTerminal(2)<CR>]], opts)
-- map('nt', '<C-x>l', [[<cmd>lua require("harpoon.term").gotoTerminal(3)<CR>]], opts)
-- map('nt', '<C-x>u', [[<cmd>lua require("harpoon.term").gotoTerminal(4)<CR>]], opts)
-- map('nt', '<C-x>i', [[<cmd>lua require("harpoon.term").gotoTerminal(5)<CR>]], opts)
-- map('nt', '<C-x>o', [[<cmd>lua require("harpoon.term").gotoTerminal(6)<CR>]], opts)
-- map('nt', '<C-x>j', [[<cmd> lua print("not broken!")<CR>]], opts)

-- removing via quick menu is simpler
map('n', '<leader>mv', [[<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>]], opts) -- mv for move to overview
map('n', '<leader>mm', [[<cmd>lua require("harpoon.mark").add_file()<CR>]], opts) -- mm means fast adding files to belly
map('n', '<leader>mc', [[<cmd>lua require("harpoon.mark").clear_all()<CR>]], opts) -- mc means fast puking away files

---- nnn ----
map('n', '<leader>ne', [[<cmd> NnnExplorer<CR>]], opts) -- file exlorer
map('n', '<leader>np', [[<cmd> NnnPicker<CR>]], opts) -- file exlorer
map('t', '<leader>ne', [[<cmd> NnnExplorer<CR>]], opts) -- file exlorer
map('t', '<leader>np', [[<cmd> NnnPicker<CR>]], opts) -- file exlorer

---- gtest ----
--map('n', ']t', [[<cmd>GTestNext<CR>]], opts)
--map('n', '[t', [[<cmd>GTestPrev<CR>]], opts)
--map('t', '<leader>tu', [[<cmd>GTestRunUnderCursor<CR>]], opts) -- lightspeed breaks this binding
--map('n', '<leader>tt', [[<cmd>GTestRun<CR>]], opts) -- lightspeed breaks this binding
