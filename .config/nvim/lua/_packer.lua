return require('packer').startup(
function()
  --There are multi cursor plugins, but there are better alternatives:
  --Visual Block mode (press Ctrl + v, press j twice to go down, go insert mode with I and after you type things will appear in all lines)
  --Macros: press qf to star recording, do whatever you have to in a line, go back 1 line with j, stop macro recording with q and execute that again with @f
  --You can also regex and use /g
  use { 'wbthomason/packer.nvim' } -- WIP : 'nvim-telescope/telescope-packer.nvim'
  use { 'nvim-telescope/telescope-project.nvim' } -- create,delete,find,search, w without opening, <leader>pr
  use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} } --teb,teff,terg,terge,teh
  use { 'nvim-telescope/telescope-dap.nvim', requires = { 'mfussenegger/nvim-dap' } }
  use { 'glepnir/lspsaga.nvim', branch = 'main', requires = { 'neovim/nvim-lspconfig' } } --gh: o,s,i,q,'<C-f>','<C-b>' --lua transition complex
  use { 'hrsh7th/nvim-compe' }
  use { 'marko-cerovac/material.nvim', config = function() require('material').set() end }
  use { 'norcalli/nvim-colorizer.lua' } --beware to use after all color config setup
  use { 'ggandor/lightspeed.nvim' } --{s,S}<c-x>?{char1}{char2}?{<tab>,<s-tab>}*{label}? {->,<-}<direction, cursor is at end of match>?char1char2?cycle*labeled jump? => f for forwards stepping
  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' }, config = function() require('gitsigns').setup() end } --<l>hs/hu,hr,hp,hb
  use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim', config = function() require('neogit').setup() end } --:Neogit
  use { 'folke/lsp-trouble.nvim', requires = "kyazdani42/nvim-web-devicons", config = function() require("trouble").setup() end } --<C-x>
  use { 'folke/which-key.nvim', config = function() require("which-key").setup() end }
  use { 'folke/todo-comments.nvim', config = function() require('todo-comments').setup() end } --:Todo(QuickFix|Trouble|Telescope)
  -- BETA: organization of stuff https://github.com/kristijanhusak/orgmode.nvim
  -- treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'mizlan/iswap.nvim' } --:Iswap
  use { 'lewis6991/spellsitter.nvim', config = function() require('spellsitter').setup() end } --'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'
  --WIP: use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  ---- VIM STUFF ----
  use { 'mcchrish/nnn.vim' } --<leader>n and :Np, TODO: setup <C-t>,<C-x>,<C-v> for file splits and adjust startup programs
  --UNNEEDED: use { 'theprimeagen/vim-be-good' } --VimBeGood,1.delete DELETE ME,2.replace contents inside first { or [ with bar, 3.navigate to caret under char ASAP+flip it
  use { 'tpope/vim-surround' } --cs"',cs'<q>,cst",ds",ysiw] => insert [] around text, {   cs]} for more space,(   yss) entire line,visual:selection S"text"
  use { 'mbbill/undotree' } -- <leader>u
  -- LANGUAGES
  use { 'ziglang/zig.vim' }

  -- https://github.com/NTBBloodbath/cheovim --missing benchmarks on loading overhead
  -- use { 'nvim-telescope/telescope-z.nvim' } --tez,<leader>z
  -- use { 'mfussenegger/nvim-lint' } --TODO c++
  -- use { 'nvim-treesitter/nvim-treesitter-refactor' } --needed?
  -- use { 'nvim-treesitter/playground' } --inspecting treesitter data: :TSPlaygroundToggle
  -- use { 'LnL7/vim-nix' } -- flakes highlighting
  -- use { 'https://gitlab.redox-os.org/redox-os/ion-vim' }
  -- use { 'JuliaEditorSupport/julia-vim' } --cool stuff: latex-to-unicode substitutions, block-wise movements and block text-objects
  -- use { 'nvim-telescope/telescope-snippets.nvim', requires = { 'norcalli/snippets.nvim' } } --how useful it is in reality => could just copy the code
  -- use { 'Iron-E/nvim-libmodal' } -- very complex for mode-specific settings (modal)
  -- use { 'brooth/far.vim' } --help var.vim: :Farf :Farr in visual and normal mode, TODO setting undo?
  -- use { 'https://gitlab.com/dbeniamine/cheat.sh-vim/' } --TODO MAPPINGS!!!
  -- use { 'mhinz/vim-rfc' }--:RFC 1000, :RFC! regex
  -- use { 'bfredl/nvim-luadev' } --lua REPL, TODO: setup
  -- use { 'bohlender/vim-smt2' }
  -- use { 'tjdevries/lsp_extensions.nvim' } --Rust,Darts only
  -- use { 'tjdevries/nlua.nvim' } --lua development helpers
end)
