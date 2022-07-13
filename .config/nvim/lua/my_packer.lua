-- stylua: ignore start
return require('packer').startup(function()
  ---- general ----
  --use { 'nanotee/nvim-lua-guide' }
  --use { 'lewis6991/impatient.nvim' }
  --use { 'nvim-lua/lsp-status.nvim' } -- necessary for statusline
  -- mkdir -p ~/.local/share/nvim/site/pack/packer/start/
  -- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  use { 'wbthomason/packer.nvim' } -- WIP : 'nvim-telescope/telescope-packer.nvim'
  use { 'marko-cerovac/material.nvim' } --<l>m
  --use { 'NMAC427/guess-indent.nvim', config = function() require('guess-indent').setup {} end } --:GuessIndent
  --use { 'ThePrimeagen/git-worktree.nvim' } -- idea project setup
  --use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
  ---- lsp+competion ----
  use { 'neovim/nvim-lspconfig' } --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
  --use { 'ms-jpq/coq_nvim', branch = 'coq' } -- autocompletion plugin for various sources, very frequent updates (ca. 4 days)
  --use { 'ms-jpq/coq.artifacts', branch = 'artifacts' } --9000+ Snippets. BUT: own way of updating may fail => annoying
  use { 'hrsh7th/cmp-buffer' } --FIXME broken
  use { 'hrsh7th/cmp-cmdline' }
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/nvim-cmp' }
  --use { 'delphinus/cmp-ctags' } -- does not search multiple files and spawns 1 process for each file
  use { 'quangnguyen30192/cmp-nvim-tags' } -- simple approach to search through tags file for completions

  ---- shiny stuff ----
  --gitsigns: [c, ]c, <l>hs/hu,hS/hR,hp(review),hb(lame),hd(iff),hD(fndiff),htb(toggle line blame),htd(toggle deleted) :Gitsigns toggle_
  --use { 'lewis6991/gitsigns.nvim', branch = 'main', config = function() require('gitsigns').setup() end }
  use { 'lewis6991/gitsigns.nvim', branch = 'main' }
  use { 'tpope/vim-fugitive' } -- TODO setup
  --:DiffviewOpen, :DiffviewClose/tabclose, :DiffviewFileHistory
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  -- idea use { 'axieax/urlview.nvim' } -- :Telescope urlview
  --requires = { 'tpope/vim-repeat' }
  -- leap: s|S char1 char2 (<space>|<tab>)* label?
  -- leap: gs in all other windows on the tab page
  -- leap: enter repeates, tab reverses the motion
  -- s|S char1 char2 <space>? (<space>|<tab>)* label?
  use { 'ggandor/leap.nvim', branch = 'main', config = function() require('leap').set_default_keymaps() end, } -- get used to enter for repeat
  use { 'luukvbaal/nnn.nvim', config = function() require('nnn').setup() end, } --<l>n and :Np
  --use { 'anuvyklack/hydra.nvim' } -- TODO finish this

  -- TODO visual mode gc,gb clash
  -- visual gc/gb, normal [count]gcc/gbc, gco/gcO/gcA
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
  -- :Neogen [function/class/type]
  use { 'danymat/neogen', config = function() require('neogen').setup {} end, requires = 'nvim-treesitter/nvim-treesitter', }
  --
  -- use { 'linty-org/key-menu.nvim' } -- idea replace which-key once https://github.com/linty-org/key-menu.nvim/issues/10 is resolved
  --use { 'numToStr/Surround.nvim' } -- still unstable like numToStr/Surround.nvim
  use { 'folke/which-key.nvim', config = function() require('which-key').setup() end, } -- :Telescope builtin.keymaps
  use { 'ThePrimeagen/harpoon' } -- <l> [m|c|s]key=[j|k|l|u|i] mv|mc|mm

  ---- telescope ----
  use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } } --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- 1.65x speed of fzf
  use { 'nvim-telescope/telescope-hop.nvim' }
  --use { '~/dev/git/lua/telescope-project.nvim' } --TODO fixit
  use { 'nvim-telescope/telescope-github.nvim' } --Telescope gh issues|pull_request|gist|run
  -- Telescope gh issues author=windwp label=bug search=miscompilation
  use { 'asbjornhaland/telescope-send-to-harpoon.nvim' } -- TODO use this
  -- TODO rename folder as you type
  --use { 'LinArcX/telescope-command-palette.nvim' } -- necessary?
  --use { 'nvim-telescope/telescope-symbols.nvim' } --:lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
  --use { 'nvim-telescope/telescope-dap.nvim', requires = { 'mfussenegger/nvim-dap' } } -- pretty printing requires codelldb (no luajit pretty printing)
  --use { 'p00f/godbolt.nvim' } -:selection?Godbolt, :selection?GodboltCompiler <compiler> <options> ie g112 -Wall\ -O2
  --use { 'nvim-telescope/telescope-project.nvim' } -- create,delete,find,search, w without opening, <l>pr => workspaces, then bare reposwor, then bare repos
  --use { '~/dev/git/nvimproj/telescope-project-scripts.nvim' } -- waiting for feedback from upstream
  -- files of telescope-project inside ~/.local/share/nvim/ telescope-project.nvim file to track workspaces not implemented yet
  --use { 'axkirillov/easypick.nvim' } -- custom telescope pickers from shell commands
  ---- treesitter ---- crashes on macro-heavy code ----
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'mizlan/iswap.nvim' } --:Iswap, as mapping :ISwapWith
  --'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'
  use { 'lewis6991/spellsitter.nvim', config = function() require('spellsitter').setup() end }

  ---- languages ----
  -- Lua
  --use { 'bfredl/nvim-luadev' } --lua repl, setup mappings for execution
  --use { 'jbyuki/one-small-step-for-vimkind', requires = { 'mfussenegger/nvim-dap' } } -- lua debugging runtime, setup
  --<Plug>(Luadev-RunLine)  Execute the current line
  --<Plug>(Luadev-Run)      Operator to execute lua code over a movement or text object.
  --<Plug>(Luadev-RunWord)  Eval identifier under cursor, including table.attr
  --<Plug>(Luadev-Complete) in insert mode: complete (nested) global table fields
  -- Zig
  --use { 'neomake/neomake' } -- get useful comments for code semantics
  use { 'LnL7/vim-nix' } -- flakes highlighting
  -- booperlv/nvim-gomove
  use { 'ziglang/zig.vim' } -- idea replacement

  ---- Organization stuff
  use { 'jbyuki/venn.nvim' } --<l>v,set ve=all,:VBox or press f,HJKL,set ve=

  ---- VIM ----
  use { 'mbbill/undotree' } -- :UndotreeToggle <l>u, rarely used
  --use { 'tpope/vim-surround' } -- ds|cs| TODO ys,yS etc is conflicting
  use { 'tpope/vim-repeat' } -- repeating with . TODO replacement
  --use { 'alepez/vim-gtest' } -- [t, ]t, <l>tu, <l>tt (careful with conflicts with telescope keybindings)
  --use { 'junegunn/vim-easy-align' } -- TODO replacement
  --use { 'junegunn/gv.vim' } -- alternative?
  --use { 'bohlender/vim-smt2' } -- grammar for syntax highlighting
  -- replacement of , vim-unimpaired, vim-speeddating, vim-repeat by optional lua functions
  -- look into https://github.com/jonatan-branting/nvim-better-n

  --use { 'vim-table' }
  --use { 'mrjones2014/legendary.nvim' } -- legend+search for keymaps, cmds, autocmds, I want to keep annotations dense+minimal
  --use { 'karb94/neoscroll.nvim', config = function() require('neoscroll').setup() end, }
  --use { 't-troebst/perfanno.nvim' } -- perf bottleneck visualizations
  --use { 'chipsenkbeil/distant.nvim' } -- remote ssh code editing and execution without fuse overhead
  --use { 'Vhyrro/neorg' } -- no use cases yet
  --use { 'mfussenegger/nvim-lint' }
  --use { 'norcalli/nvim-colorizer.lua' } -- use after all colors are setup, only necessary for color work
  --use { 'theprimeagen/vim-be-good' } --for beginners VimBeGood,1.delete DELETE ME,2.replace contents inside first { or [ with bar, 3.navigate to caret under char ASAP+flip it
  --use { 'wilder.nvim'} -- auto completion for :e and alike
  --use { 'junegunn/fzf.vim', requires = { 'junegunn/fzf', run = ':call fzf#install()' } } -- telescope has same algorithm + better performance
  --use { 'nvim-telescope/telescope-z.nvim' } --tez,<l>z -- would be clutch to have telescope project support
  --use { 'nvim-treesitter/nvim-treesitter-refactor' } -- block-wise movement and file-local replacements
  --use { 'nvim-treesitter/playground' } --inspecting treesitter data: :TSPlaygroundToggle
  --use { 'JuliaEditorSupport/julia-vim' } --cool stuff: latex-to-unicode substitutions, block-wise movements and block text-objects
  --use { 'nvim-telescope/telescope-snippets.nvim', requires = { 'norcalli/snippets.nvim' } } -- useful for loop stuff
  --use { 'https://gitlab.com/dbeniamine/cheat.sh-vim/' }
  --use { 'mhinz/vim-rfc' }--:RFC 1000, :RFC! regex
  --use { 'bohlender/vim-smt2' }
  --use { 'tjdevries/lsp_extensions.nvim' } --Rust,Darts only
  --use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim', config = function() require('neogit').setup() -- --:Neogit -- very complex
  --use { 'folke/lsp-trouble.nvim', requires = 'kyazdani42/nvim-web-devicons', config = function() require("trouble").setup() end } --:Trouble,<l>xx/xw/xd/xl/xq/xr
  --use { 'folke/todo-comments.nvim', config = function() require('todo-comments').setup() end } --:Todo(QuickFix|Trouble|Telescope) for hack,todo,fixme
end)
-- stylua: ignore end
