-- options and global variables --
--vim.o.guicursor         = '';
local function load_options()
  local setvars = {
    python3_host_prog = '/usr/bin/python3',
    rg_derive_root = true,
    rustfmt_autosave = true,
    vim_apm_log = true, -- ???
    --vim_be_good_log_file = true,
    mapleader = ' ',
    material_style = 'lighter', -- default, darker, lighter, oceanic, deep ocean, palenight
    material_lighter_contrast = false,
    nvimgdb_use_cmake_to_find_executables = 0, -- nvim-gdb workaround: autosearch breaks plugin
    --coq_settings = { auto_start = true },
    --doge_mapping = "<leader>do"; --idea get doge to work
    --netrw_browse_split = 0
    --netrw_banner = 0
    --netrw_winsize = 25
    --netrw_localrmdir = 'rm -r'
  }
  for k, v in pairs(setvars) do
    vim.api.nvim_set_var(k, v)
  end
  --vim.g['gtest#gtest_command'] = 'build/runTests' -- test binary location
  vim.o.backup = false
  -- based on github.com/neovim/neovim/12092 and wiki
  -- 33a747a92da60fb65e668edbf7661d3d902411a2d545fe9dc08623cecd142a20  win32yank.zip
  -- curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
  -- unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
  -- chmod +x /tmp/win32yank.exe
  -- sudo mv /tmp/win32yank.exe /usr/local/bin/
  vim.o.clipboard = 'unnamedplus' -- use system clipboard (broken in firefox)
  vim.o.cmdheight = 0 -- shortcut vim.o.ch
  vim.o.completeopt = 'menuone,noselect' -- also used with coq_nvim
  --vim.o.completeopt = 'menu,menuone,noselect' --nvim-cmp
  vim.o.cursorline = true
  vim.o.errorbells = false
  vim.o.hidden = true
  vim.o.hlsearch = true --false
  vim.o.ignorecase = true --lower case chars also search for upper ones
  vim.o.incsearch = true --highlight as searching
  vim.o.isfname = vim.o.isfname .. ',@-@'
  --vim.o.laststatus = 3 --one global statusline instead of per window
  vim.o.laststatus = 3 --disappearing statusline
  vim.o.lazyredraw = true -- do not redraw screen in mid of macro
  vim.o.mouse = 'nv'
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.shortmess = vim.o.shortmess .. 'c'
  vim.o.showmode = false
  vim.o.signcolumn = 'yes'
  vim.o.smartcase = true --automatic lower except when upper chars
  vim.o.smartindent = true
  vim.o.swapfile = false
  vim.o.termguicolors = true
  vim.o.undodir = os.getenv 'HOME' .. '/.config/nvim/undodir' --undotree
  vim.o.undofile = true
  vim.o.updatetime = 50
  vim.o.wildmode = 'longest,list' --C-d: possible completions, C-n|p cycle results
  --vim.o.scrolloff         = 8; view movements: z+b|z|t, <C>+y|e (one line), ud (halfpage), bf (page, cursor to last line)
  vim.wo.colorcolumn = '80'
  vim.wo.list = true
  vim.wo.listchars = 'tab:⇨|,nbsp:␣,trail:‗,extends:>,precedes:<' --eol:↵, tab:|⇆⇥_, tab:‗‗,
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = 'yes'
  vim.wo.spell = false
  vim.wo.wrap = false

  vim.bo.spelllang = 'en,de'
  vim.bo.swapfile = false

  -- note: https://stackoverflow.com/a/159065
  --vim.bo.expandtab = false --use Tab character on pressing Tab key
  vim.bo.expandtab = false --expand tabs to spaces: use fuzzy impl
  vim.bo.shiftwidth = 2 --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop = 2 --Tab key: number of spaces for indendation
  vim.bo.scrollback = 100000 -- terminal scrollback
  -- tabstop/expandtab breaks inconsistently for c++ and lua

  -- :retab just works, so no need for extab
  --set softtabstop=4
end

load_options()
