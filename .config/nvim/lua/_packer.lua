return require('packer').startup(
function()
  --use { 'nanotee/nvim-lua-guide' }
  use { 'wbthomason/packer.nvim' } -- WIP : 'nvim-telescope/telescope-packer.nvim'
  use { 'neovim/nvim-lspconfig' } --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
  use { 'ms-jpq/coq_nvim', branch = 'coq'} -- autocompletion plugin for various sources, TODO try to replace
  use { 'ms-jpq/coq.artifacts', branch= 'artifacts'} --9000+ Snippets, TODO try to replace
  use { 'marko-cerovac/material.nvim' } --<l>m
  -- use { 'norcalli/nvim-colorizer.lua' } -- use after all colors are setup, only necessary for color work
  use { 'ggandor/lightspeed.nvim' } --{s,S}<c-x>?{char1}{char2}?{<tab>,<s-tab>}*{label}? {->,<-}<direction, cursor is at end of match>?char1char2?cycle*labeled jump? => f for forwards stepping
  use { 'lewis6991/gitsigns.nvim', branch = 'main', requires = { 'nvim-lua/plenary.nvim' }, config = function() require('gitsigns').setup() end } --]c, [c, <l>hs/hu,hr,hp,hb :Gitsigns toggle_
  -- use { 'folke/lsp-trouble.nvim', requires = 'kyazdani42/nvim-web-devicons', config = function() require("trouble").setup() end } --:Trouble,<l>xx/xw/xd/xl/xq/xr
  use { 'folke/which-key.nvim', config = function() require("which-key").setup() end } -- alternative lazytanuki/nvim-mapper
  use { 'folke/todo-comments.nvim', config = function() require('todo-comments').setup() end } --:Todo(QuickFix|Trouble|Telescope)
  -- use { 'shadmansaleh/lualine.nvim',  requires = {'kyazdani42/nvim-web-devicons' } }
  ---- telescope ----
  use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} } --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- 1.65x speed of fzf
  use { '~/dev/git/lua/telescope-project.nvim' } -- TODO finish workspaces
  -- use { 'nvim-telescope/telescope-dap.nvim', requires = { 'mfussenegger/nvim-dap' } } --TODO printing complex variables for zig/c++ tutorial
  --use { '~/dev/git/nvimproj/telescope-project-scripts.nvim' } -- waiting for feedback from upstream
  --use { 'nvim-telescope/telescope-project.nvim' } -- create,delete,find,search, w without opening, <leader>pr
  -- files of telescope-project inside ~/.local/share/nvim/ telescope-project.nvim file to track workspaces not implemented yet
  --use { 'nvim-telescope/telescope-symbols.nvim' } --:lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
  --use { 'nvim-telescope/telescope-github.nvim' } -- TODO: setup
  ---- treesitter ---- performance problems and crashes on macro-heavy code) ----
  --use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  --use { 'mizlan/iswap.nvim' } --:Iswap
  --use { 'lewis6991/spellsitter.nvim', config = function() require('spellsitter').setup() end } --'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'
  -- use { 'Vhyrro/neorg' } -- problem: treesitter performance
  ---- VIM STUFF ----
  -- try to use vim filebrowser, which has fuzzy completion
  --use { 'mcchrish/nnn.vim' } --<leader>n and :Np, TODO: setup <C-t>,<C-x>,<C-v> for file splits and adjust startup programs
  --use { 'mbbill/undotree' } -- <leader>u, rarely used
  -- LANGUAGES
  use { 'bfredl/nvim-luadev' } --lua repl, TODO setup mappings for execution
  use { 'jbyuki/one-small-step-for-vimkind' } -- lua debugging runtime, TODO setup
  --<Plug>(Luadev-RunLine) 	Execute the current line
  --<Plug>(Luadev-Run) 	Operator to execute lua code over a movement or text object.
  --<Plug>(Luadev-RunWord) 	Eval identifier under cursor, including table.attr
  --<Plug>(Luadev-Complete) 	in insert mode: complete (nested) global table fields
  use { 'ziglang/zig.vim' }
  --use { 'rust-tools.nvim' }

  -- use { 'NTBBloodbath/cheovim' } -- TODO setup
  -- use { 'mfussenegger/nvim-lint' } -- TODO c++
  -- use { 'junegunn/vim-easy-align' } -- TODO keybindings
  -- use { 'junegunn/gv.vim' } -- alternative?
  -- replacement of vim-surround, vim-unimpaired, vim-speeddating, vim-repeat by optional lua functions

  -- beginners: use { 'theprimeagen/vim-be-good' } --VimBeGood,1.delete DELETE ME,2.replace contents inside first { or [ with bar, 3.navigate to caret under char ASAP+flip it
  -- use { 'wilder.nvim'} -- auto completion for :e and alike
  -- use { 'junegunn/fzf.vim', requires = { 'junegunn/fzf', run = ':call fzf#install()' } } -- telescope has same algorithm + better performance
  -- use { 'nvim-telescope/telescope-z.nvim' } --tez,<leader>z -- would be clutch to have telescope project support
  -- use { 'nvim-treesitter/nvim-treesitter-refactor' } -- block-wise movement and file-local replacements
  -- use { 'nvim-treesitter/playground' } --inspecting treesitter data: :TSPlaygroundToggle
  -- use { 'LnL7/vim-nix' } -- flakes highlighting
  -- use { 'JuliaEditorSupport/julia-vim' } --cool stuff: latex-to-unicode substitutions, block-wise movements and block text-objects
  -- use { 'nvim-telescope/telescope-snippets.nvim', requires = { 'norcalli/snippets.nvim' } } -- useful for loop stuff
  -- use { 'https://gitlab.com/dbeniamine/cheat.sh-vim/' }
  -- use { 'mhinz/vim-rfc' }--:RFC 1000, :RFC! regex
  -- use { 'bohlender/vim-smt2' }
  -- use { 'tjdevries/lsp_extensions.nvim' } --Rust,Darts only
  -- use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim', config = function() require('neogit').setup() -- --:Neogit -- very complex
end)
