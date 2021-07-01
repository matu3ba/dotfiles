-- options and global variables --
--vim.o.guicursor         = '';
local function load_options()
  local setvars = {
    python3_host_prog = "/usr/bin/python3";
    rg_derive_root = true;
    rustfmt_autosave = true;
    vim_apm_log = true;
    vim_be_good_log_file = true;
    mapleader = " ";
    material_style = "lighter"; -- default, darker, lighter, oceanic, deep ocean, palenight
    material_lighter_contrast = false;
    --doge_mapping = "<leader>d";
  }
  for k, v in pairs(setvars) do
    vim.api.nvim_set_var(k, v);
  end
  vim.o.backup            = false;
  vim.o.clipboard         = 'unnamedplus'; -- use system clipboard (broken in firefox)
  vim.o.cmdheight         = 2;
  vim.o.completeopt       = 'menuone,noselect';
  vim.o.cursorline        = true;
  vim.o.errorbells        = false;
  vim.o.hidden            = true;
  vim.o.hlsearch          = true; --false
  vim.o.incsearch         = true; --highlight as searching
  vim.o.isfname           = vim.o.isfname .. ',@-@';
  vim.o.mouse             = "nv";
  vim.o.number            = true;
  vim.o.relativenumber    = true;
  vim.o.scrolloff         = 8;
  vim.o.shortmess         = vim.o.shortmess .. 'c';
  vim.o.showmode          = false;
  vim.o.signcolumn        = 'yes';
  vim.o.smartcase         = true; --automatic lower except when upper chars
  vim.o.smartindent       = true;
  vim.o.swapfile          = false;
  vim.o.termguicolors     = true;
  vim.o.undodir           = os.getenv("HOME") .. '/.config/nvim/undodir'; --undotree
  vim.o.undofile          = true;
  vim.o.updatetime        = 50;

  vim.wo.colorcolumn       = '80';
  vim.wo.list              = true;
  vim.wo.listchars         = 'trail:‗,tab:⇥_,nbsp:␣'; --eol:↵,
  vim.wo.number           = true;
  vim.wo.relativenumber   = true;
  vim.wo.signcolumn       = 'yes';
  vim.wo.spell            = false;
  vim.wo.wrap             = false;

  vim.bo.spelllang        = 'en,de'
  vim.bo.swapfile         = false;

  vim.bo.expandtab        = true; --use space character on pressing Tab key
  vim.bo.shiftwidth       = 2; --visual mode >,<-key: number of spaces for indendation
  vim.bo.tabstop          = 2; --Tab key: number of spaces for indendation
end

load_options()
