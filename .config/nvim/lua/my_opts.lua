--! Options and global variables
-- luacheck: globals vim
-- luacheck: no max line length
local utils = require 'my_utils'

-- Most often used toggle options
-- :set binary nobinary
-- :setlocal display=uhex

-- overwrite showing of fileformat for inspection, see :h ++ff
-- easier to use
-- fd --type f . -x dos2unix
-- fd --type f . -x unix2dos
-- :e ++ff=unix file.txt
-- :w ++ff=unix file.txt
-- :e ++enc=utf-8 file.txt
-- :w ++enc=latin1 newfile

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
    python3_host_prog = vim.fn.exepath('python'), -- for virtualenv use linux-cultist/venv-selector.nvim
    rg_derive_root = true,
    rustfmt_autosave = true,
    -- libbuf_log_level = "trace",
    loaded_perl_provider = 0, -- no checkhealth errors
    loaded_ruby_provider = 0,
    loaded_node_provider = 0,
    loaded_python_provider = 0,
    loaded_python3_provider = 0,
  }
  for k, v in pairs(setvars) do
    vim.api.nvim_set_var(k, v)
  end
  --vim.g['gtest#gtest_command'] = 'build/runTests' -- test binary location
  -- vim.o.backupdir = utils.pathJoin(vim.fn.stdpath 'state', 'backup') -- not useful, cant be turned off in cli
  vim.o.backup = false
  -- window size is written by terminal and given as
  -- vim.o.columns/vim.o.lines
  -- clipboard :h clipboard-osc52, :h clipboard-wsl, :h
  -- use Windows Terminal, a terminal supporting osc52 or add logic below
  if vim.version()["minor"] >= 10 and utils.isRemoteSession() then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.clipboard.osc52').copy,
        ['*'] = require('vim.clipboard.osc52').copy,
      },
      paste = {
        ['+'] = require('vim.clipboard.osc52').paste,
        ['*'] = require('vim.clipboard.osc52').paste,
      },
    }
  elseif utils.isWSL() then
    vim.g.clipboard = {
      name = 'WslClipboard',
      copy = {
        ['+'] = 'clip.exe',
        ['*'] = 'clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      },
      cache_enabled = 0,
    }
  else
    vim.o.clipboard = 'unnamedplus' -- system clipboard (broken in firefox)
  end
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
  -- vim.o.grepprg = 'grepprg' -- default: grep -n $* /dev/null
  -- vim.o.grepformat = '%f:%l:%c:%m,%f:%l:%m' -- default: %f:%l:%m,%f:%l%m,%f  %l%m
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
  vim.o.undodir = utils.pathJoin(vim.fn.stdpath 'state', 'undodir') --undodir
  vim.o.undofile = true
  vim.o.updatetime = 50
  vim.o.wildmode = 'longest,list' --C-d: possible completions, C-n|p cycle results
  vim.o.scrollback = 100000 -- max terminal scrollback without autcommand annoyance
  if vim.fn.has 'win32' == 1 then
    -- PowerShellEditorServices https://github.com/PowerShell/PowerShellEditorServices
    -- SHENNANIGAN This setup is not the default behavior for neovim with default actions not working out of the box:
    -- :'<,'>:w !git<CR>
    -- :.!git<CR>
    -- https://stackoverflow.com/questions/2575545/vim-pipe-selected-text-to-shell-cmd-and-receive-output-on-vim-info-command-line
    if vim.fn.executable("pwsh.exe") == 1 then
      vim.o.shell =  "pwsh.exe"
      vim.o.shellcmdflag = "-NonInteractive -NoLogo -ExecutionPolicy RemoteSigned -Command "
    else
      vim.opt.shell =  "powershell.exe"
      vim.o.shellcmdflag = "-NonInteractive -NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8 "
    end
    vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
  else
    vim.o.shell = 'fish'
  end
  -- https://vi.stackexchange.com/questions/3484/disable-swap-file-for-large-files
  -- https://vim.fandom.com/wiki/Faster_loading_of_large_files
  -- disable with -n or :set noswapfile
  --   nvim -u NONE or use less
  --   unusing all the plugins etc https://github.com/LunarVim/bigfile.nvim
  vim.o.directory = utils.pathJoin(vim.fn.stdpath 'state', 'swap') --swap directory
  vim.o.swapfile = true
  -- spell: 'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'
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

  -- TODO :set formatoptions-=cro
  -- to fix //-comments being annoying
  -- https://superuser.com/questions/271023/can-i-disable-continuation-of-comments-to-the-next-line-in-vim

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