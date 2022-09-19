-- stylua: ignore start
return require('packer').startup(function()
  -- use { 'lewis6991/impatient.nvim' }
  ---- general ----
  --use { 'nanotee/nvim-lua-guide' }
  -- mkdir -p ~/.local/share/nvim/site/pack/packer/start/
  -- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  use { 'wbthomason/packer.nvim' } -- WIP : 'nvim-telescope/telescope-packer.nvim'
  use { 'marko-cerovac/material.nvim' } --<l>ma
  -- TODO: publish the git worktree helper scripts
  --use { 'ThePrimeagen/git-worktree.nvim' } -- idea project setup
  ---- lsp+competion ----
  use { 'williamboman/mason.nvim', config = function() require("mason").setup() end, }
  use { 'neovim/nvim-lspconfig' } --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
  --use { 'hrsh7th/cmp-buffer' } -- broken: https://github.com/hrsh7th/cmp-buffer/issues/54
  use { 'hrsh7th/cmp-cmdline' } -- TODO: deactivate completions for :e (broken for that use case)
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-path' }
  use { 'hrsh7th/nvim-cmp' }

  ---- shiny stuff ----
  --gitsigns: [c, ]c, <l>hs/hu,hS/hR,hp(review),hb(lame),hd(iff),hD(fndiff),htb(toggle line blame),htd(toggle deleted) :Gitsigns toggle_
  --use { 'lewis6991/gitsigns.nvim', branch = 'main', config = function() require('gitsigns').setup() end }
  use { 'lewis6991/gitsigns.nvim', branch = 'main' }
  --use { 'tpope/vim-fugitive' } -- idea try without, find plugin for in buffer interative rebasing
  --:DiffviewOpen, :DiffviewClose/tabclose, :DiffviewFileHistory
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  -- idea use { 'axieax/urlview.nvim' } -- :Telescope urlview
  --requires = { 'tpope/vim-repeat' }
  -- leap: s|S char1 char2 (<space>|<tab>)* label?
  -- leap: gs in all other windows on the tab page
  -- leap: enter repeates, tab reverses the motion
  -- s|S char1 char2 <space>? (<space>|<tab>)* label?
  -- -|_ char1 char2 <space>? (<space>|<tab>)* label?
  use { 'ggandor/leap.nvim', branch = 'main', } -- repeat action not yet supported
  --use { 'luukvbaal/nnn.nvim', config = function() require('nnn').setup() end, } --<l>n and :Np

  -- :Dirbuf, <CR>, gh (toggel hidden files), -, :w[rite], C-m on path to open dir in dirbuf
  use { 'elihunter173/dirbuf.nvim', config = function() require("dirbuf").setup { write_cmd = "DirbufSync -confirm" } end, }
  use { 'anuvyklack/hydra.nvim' } -- my_hydra.lua

  -- TODO visual mode gc,gb clash
  -- visual gc/gb, normal [count]gcc/gbc, gco/gcO/gcA
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end, }
  -- :Neogen [function/class/type]
  use { 'danymat/neogen', config = function() require('neogen').setup {} end, requires = 'nvim-treesitter/nvim-treesitter', }

  -- use { 'nicwest/vim-camelsnek' } -- idea setup
  -- selection S' to put ' around selected text
  -- ysiw' for inner word with '
  -- ? support for ysiwf ?
  -- word -> ysiw' -> 'word'
  -- *word_another bla -> ysit<space>" -> "word_another"* bla
  -- (da da) ->(  ysa") -> ("da da")
  use { 'kylechui/nvim-surround', config = function() require("nvim-surround").setup() end, } -- stylish
  -- gm, M to mark word/region, M delete word
  -- g!M matches only full word
  -- do stuff, r, e etc
  -- press M or C-b to finish editing record and go forward/backward
  -- keep pressing M or C-b to reapply changes in selection
  -- press <CR> to mark match at cursor ignored
  -- navigate without changing with C-j, C-k
  -- ga: change all occurences
  use { 'otavioschwanck/cool-substitute.nvim', config = function() require'cool-substitute'.setup{ setup_keybindings = true } end, }
  use { 'folke/which-key.nvim', config = function() require('which-key').setup() end, } -- :Telescope builtin.keymaps
  use { 'ThePrimeagen/harpoon' } -- <l> [m|c|s]key=[j|k|l|u|i] mv|mc|mm, :CKey, :CCmd

  ---- telescope ----
  use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } } --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- 1.65x speed of fzf
  --use { 'nvim-telescope/telescope-hop.nvim' } -- TODO fix setup: no numbers are showing up
  -- Telescope gh issues author=windwp label=bug search=miscompilation
  use { 'nvim-telescope/telescope-github.nvim' } --Telescope gh issues|pull_request|gist|run
  ---- treesitter ---- crashes on macro-heavy code ----
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'mizlan/iswap.nvim' } --:Iswap, as mapping :ISwapWith
  --'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'

  ---- languages ----
  -- Lua
  --use { 'bfredl/nvim-luadev' } --lua repl, setup mappings for execution
  --use { 'jbyuki/one-small-step-for-vimkind', requires = { 'mfussenegger/nvim-dap' } } -- lua debugging runtime, setup
  --<Plug>(Luadev-RunLine)  Execute the current line
  --<Plug>(Luadev-Run)      Operator to execute lua code over a movement or text object.
  --<Plug>(Luadev-RunWord)  Eval identifier under cursor, including table.attr
  --<Plug>(Luadev-Complete) in insert mode: complete (nested) global table fields
  --TODO: find something like scrollbackedit from zellij for neovim terminal
  --TODO masterplan: Vim macro to lua function translation
  --  1. read current keybinding including inbuilds => refactor core keyevent handling in neoim (https://github.com/linty-org/key-menu.nvim/issues/10)
  --  2. track the mode, last action and read keys to lookup next action => or capture this in neovim without executing it
  -- related: use { 'linty-org/key-menu.nvim' } -- idea replace which-key once https://github.com/linty-org/key-menu.nvim/issues/10 is resolved
  -- Zig
  --use { 'neomake/neomake' } -- get useful comments for code semantics
  use { 'LnL7/vim-nix' } -- flakes highlighting: wait until nix converts their stuff to flakes
  -- booperlv/nvim-gomove
  use { 'ziglang/zig.vim' } -- idea replacement
  ---- Organization stuff
  use { 'jbyuki/venn.nvim' } --hydra: <l>v without: set ve=all,:VBox or press f,HJKL,set ve=
  ---- VIM ----
  use { 'mbbill/undotree' } -- :UndotreeToggle <l>u, rarely used

  -- use { 'nvim-telescope/telescope-dap.nvim', requires = { 'mfussenegger/nvim-dap' } } -- idea setup
  -- use { 'theHamsta/nvim-dap-virtual-text',  'rcarriga/nvim-dap-ui' } -- idea setup + comapre with harpoon approach

  --problem: https://github.com/asbjornhaland/telescope-send-to-harpoon.nvim/issues/1
  --workaround: command
  --use { 'asbjornhaland/telescope-send-to-harpoon.nvim' } -- required: telescope,harpoon,
  --use { 'LinArcX/telescope-command-palette.nvim' } -- necessary?
  --use { 'nvim-telescope/telescope-symbols.nvim' } --:lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
  --use { '~/dev/git/lua/telescope-project.nvim' } -- idea fixit
  --use { 'nvim-telescope/telescope-project.nvim' } -- create,delete,find,search, w without opening, <l>pr => workspaces, then bare reposwor, then bare repos
  --use { '~/dev/git/nvimproj/telescope-project-scripts.nvim' } -- waiting for feedback from upstream
  -- files of telescope-project inside ~/.local/share/nvim/ telescope-project.nvim file to track workspaces not implemented yet
  --use { 'axkirillov/easypick.nvim' } -- custom telescope pickers from shell commands

  --use { 'ms-jpq/coq_nvim', branch = 'coq' } -- autocompletion plugin for various sources, very frequent updates (ca. 4 days)
  --use { 'ms-jpq/coq.artifacts', branch = 'artifacts' } --9000+ Snippets. BUT: own way of updating may fail => annoying
  --use { 'delphinus/cmp-ctags' } -- does not search multiple files and spawns 1 process for each file
  --use { 'quangnguyen30192/cmp-nvim-tags' } -- simple approach to search through tags file for completions
  --use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }
  --use { 'nvim-lua/lsp-status.nvim' } -- nice to have for statusline
  --use { 'NMAC427/guess-indent.nvim', config = function() require('guess-indent').setup {} end } --:GuessIndent
  --use { 'p00f/godbolt.nvim' } -:selection?Godbolt, :selection?GodboltCompiler <compiler> <options> ie g112 -Wall\ -O2
  --use { 'junegunn/vim-easy-align' } -- idea replacement
  --use { 'alepez/vim-gtest' } -- [t, ]t, <l>tu, <l>tt (careful with conflicts with telescope keybindings)
  --use { 'junegunn/gv.vim' } -- alternative?
  --use { 'bohlender/vim-smt2' } -- grammar for syntax highlighting
  -- replacement of vim-unimpaired, vim-speeddating, vim-repeat by optional lua functions
  -- look into https://github.com/jonatan-branting/nvim-better-n
  --use { 'tpope/vim-repeat' } -- repeating with ., superseded with https://this-week-in-neovim.org/2022/Aug/15#article-dot-repeat
  --use { 'phaazon/hop.nvim', config = function() require'hop'.setup() end, }
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
end)
-- stylua: ignore end
