--! Options and global variables
-- luacheck: globals vim
-- luacheck: no max line length
local utils = require 'my_utils'

--vim.o.guicursor         = '';
local function load_options()
  local setvars = {
    --coq_settings = { auto_start = true },
    --doge_mapping = "<leader>dog"; --idea get doge to work
    --vim_be_good_log_file = true,
    mapleader = ' ',
    material_lighter_contrast = false,
    material_style = 'palenight', -- default, darker, lighter, oceanic, deep ocean, palenight
    -- nvimgdb_use_cmake_to_find_executables = 0, -- nvim-gdb too slow
    -- nvimgdb_use_find_executables = 0, -- nvim-gdb too slow
    python3_host_prog = '/usr/bin/python3',
    rg_derive_root = true,
    rustfmt_autosave = true,
    -- libbuf_log_level = "trace",
  }
  for k, v in pairs(setvars) do
    vim.api.nvim_set_var(k, v)
  end
  --vim.g['gtest#gtest_command'] = 'build/runTests' -- test binary location
  vim.o.backup = false
  -- window size is written by terminal and given as
  -- vim.o.columns/vim.o.lines
  -- windows:
  -- based on github.com/neovim/neovim/12092 and wiki
  -- 33a747a92da60fb65e668edbf7661d3d902411a2d545fe9dc08623cecd142a20  win32yank.zip
  -- curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
  -- unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
  -- chmod +x /tmp/win32yank.exe
  -- sudo mv /tmp/win32yank.exe /usr/local/bin/
  -- win HACK: vnoremap <silent> <C-v> :!powershell.exe -command "Get-Clipboard" 2> /dev/null<CR>
  -- JUST WORKS: use <C-V> to paste, holding shift + selecting with mouse and press <C-v> (also deselect) or <C-V> to only copy
  -- putty (configuration in menu "selection"), wsl shell and zellij affect usable clipboard:
  -- only putty => x clipboard available: only shift selection works (ssh target system copy)
  -- only wsl => error invoking win32yank: only shift selection works (also no local copy)
  -- putty + zellij => x clipboard available: only shift selection works (ssh target system copy)
  -- wsl + zellij => win32yank available: mouse selection + y works, yy does not
  vim.o.clipboard = 'unnamedplus' -- use system clipboard (broken in firefox)
  vim.o.cmdheight = 0 -- shortcut vim.o.ch
  vim.o.completeopt = 'menuone,noselect' -- also used with coq_nvim
  --vim.o.completeopt = 'menu,menuone,noselect' --nvim-cmp
  vim.o.cursorline = true
  -- # EditorConfig as defined in https://EditorConfig.org
  -- root = true
  -- charset = utf-8
  -- [{*.h,*.c,*.cpp}]
  -- indent_style = tab
  -- indent_size = tab
  -- tab_width = 2
  -- # Indentation override for JS files under lib directory
  -- # [lib/**.js]
  -- # indent_style = space
  -- # indent_size = 2
  -- vim.g.editorconfig = true -- add .editorconfig, see editorconfig.org
  vim.o.errorbells = false
  vim.o.hidden = true
  vim.o.hlsearch = true --false
  vim.o.ignorecase = true --lower case chars also search for upper ones
  vim.o.incsearch = true --highlight as searching
  vim.o.isfname = vim.o.isfname .. ',@-@'
  --vim.o.laststatus = 3 --one global statusline instead of per window
  vim.o.laststatus = 3 --disappearing statusline
  vim.o.lazyredraw = true -- no redraw screen in mid of macro
  vim.o.mouse = 'nv'
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.shortmess = vim.o.shortmess .. 'c'
  vim.o.showmode = false
  vim.o.signcolumn = 'yes'
  vim.o.smartcase = true --automatic lower except when upper chars
  vim.o.smartindent = true
  vim.o.termguicolors = true
  -- neovim core has to this date no path functions + separator in core and neither stdpath
  vim.o.undodir = utils.pathJoin(vim.fn.stdpath('config'), 'undodir') --undotree
  vim.o.undofile = true
  vim.o.updatetime = 50
  vim.o.wildmode = 'longest,list' --C-d: possible completions, C-n|p cycle results
  vim.o.scrollback = 100000 -- max terminal scrollback without autcommand annoyance
  vim.o.shell = 'fish'
  vim.o.swapfile = false
  vim.o.spelllang = 'en,de'
  --vim.o.scrolloff         = 8; view movements: z+b|z|t, <C>+y|e (one line), ud (halfpage), bf (page, cursor to last line)
  vim.wo.colorcolumn = '80,120,150'
  vim.wo.list = true
  vim.wo.listchars = 'tab:⇨|,nbsp:␣,trail:‗,extends:>,precedes:<' --eol:↵, tab:|⇆⇥_, tab:‗‗,
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = 'yes'
  vim.wo.spell = false
  vim.wo.wrap = false

  -- print current filetype for nvim, treesitter
  -- :lua print(vim.bo.filetype)
  -- :lua print(require("nvim-treesitter.parsers").filetype_to_parsername[vim.bo.filetype])
  -- see also :h comment.ft.calculate

  -- buffer options are only applied from within the buffer, ie via autocommand.
  -- note: https://stackoverflow.com/a/159065
  -- vim.bo.expandtab = false --use Tab character on pressing Tab key
  -- vim.bo.expandtab = false --expand tabs to spaces: use fuzzy impl
  -- vim.bo.shiftwidth = 2 --visual mode >,<-key: number of spaces for indendation
  -- vim.bo.tabstop = 2 --Tab key: number of spaces for indendation
  -- tabstop/expandtab breaks inconsistently for c++ and lua

  -- :retab just works, so no need for extab
  --set softtabstop=4
  --:lua vim.env.LD_LIBRARY_PATH="./lib", :let $LD_LIBRARY_PATH = "./lib"
end

load_options()
