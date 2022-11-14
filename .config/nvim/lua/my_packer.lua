-- stylua: ignore start
return require('packer').startup(function()
  -- use { 'lewis6991/impatient.nvim' }
  ---- general ----
  --use { 'nanotee/nvim-lua-guide' }
  -- mkdir -p ~/.local/share/nvim/site/pack/packer/start/
  -- git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
  use { 'wbthomason/packer.nvim' } -- WIP : 'nvim-telescope/telescope-packer.nvim'
  use { 'marko-cerovac/material.nvim' } --<l>ma
  use { 'ojroques/vim-oscyank' } -- copy paste with ssh, zellij also supports ANSI OSC52
  -- TODO: publish the git worktree helper scripts
  ---- lsp+competion ----
  use { 'williamboman/mason.nvim', config = function() require("mason").setup() end, }
  use { 'neovim/nvim-lspconfig' } --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
  ---- completions ----
  -- C-x + C-n|p | C-f | C-k  buffer, filepaths, keywords
  -- C-x + C-l | C-s | C-t    lines, spell, thesaurus
  -- C-x + C-v | C-z | C-]    vim, stop, tags
  -- C-x + C-o                user function (omnifunction)
  -- C-x + C-u                user function (completefunc)
  -- C-x + C-d | C-i          macros, include paths
  use { 'hrsh7th/nvim-cmp' }
  use { 'hrsh7th/cmp-nvim-lsp' }
  -- use { 'hrsh7th/cmp-path' } -- performance problems (no timeout etc)
  -- use { 'hrsh7th/cmp-buffer' } -- broken: https://github.com/hrsh7th/cmp-buffer/issues/54
  use { 'hrsh7th/cmp-cmdline' } -- completions for :e, /, buffer are broken
  -- Harpoon idea: terminal view with custom binding to have something like gdb:
  -- server pwd > register  +  cat filename under cursor
  -- Idea: pipe things (append or overwrite) into scratch buffer window to gf it
  -- => workaround for wraparound not working

  -- default mappings: textobjects: ii, ai, goto: [i,]i
  -- no color support yet: https://github.com/echasnovski/mini.nvim/issues/99
  use { 'echasnovski/mini.indentscope', config = function() require("mini.indentscope").setup({}) end, }
  -- ga no preview, gA preview
  use { 'echasnovski/mini.align', config = function() require("mini.align").setup({}) end, }
  -- a,i main prefixes, an,in,al,il next last textobject, g[,g] movement
  use { 'echasnovski/mini.ai', config = function() require("mini.ai").setup({}) end, }
  --use { 'echasnovski/mini.completion' } -- TODO: think how to configure nvim-cmp to use something else than C-n|p
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
  -- (unused default breaks nvim-surround) s|S char1 char2 <space>? (<space>|<tab>)* label?
  -- -|_ char1 char2 <space>? (<space>|<tab>)* label?
  use { 'ggandor/leap.nvim', branch = 'main', } -- repeat action not yet supported

  -- :GdbStart gdb -tui exec, :GdbStart gdb -tui --args exec arg1 ..,
  -- :GdbStart gdb -tui -x SCRIPT exec
  -- :Gdb command
  -- <f4>   Until                        (`:GdbUntil`)
  -- <f5>   Continue                     (`:GdbContinue`)
  -- <f6>   Reverse-Next                 (`:TODO`), TODO
  -- <f7>   Reverse-Step                 (`:TODO`), TODO
  -- <f10>  Next                         (`:GdbNext`)
  -- <f11>  Step                         (`:GdbStep`)
  -- <f12>  Finish                       (`:GdbFinish`)
  -- <f8>   Toggle breakpoint            (`:GdbBreakpointToggle`)
  -- <c-p>  Frame Up                     (`:GdbFrameUp`)
  -- <c-n>  Frame Down                   (`:GdbFrameDown`)
  -- <f9> NORMAL: Eval word under cursor (`:GdbEvalWord`)
  --      VISUAL: Eval the range         (`:GdbEvalRange`)
  -- see nvimgdb#GlobalInit() for commands and lua functions like NvimGdb.i():send('f')
  -- hover, goto frame, exit + edit history with latest debug point action
  -- saved in file with increased number, default to latest number on selection
  -- TODO: build your own mouse hover? (use f9 to print locals instead of auto)
  -- TODO: scratch window for gdb history, awaiting response https://github.com/sakhnik/nvim-gdb/issues/177
  -- https://github.com/neovim/neovim/wiki/FAQ#debug
  -- enable coredumps: ulimit -c unlimited
  -- if needed: systemd-coredump
  -- coredumpctl -1 gdb
  --2>&1 coredumpctl -1 gdb | tee -a bt.txt
  -- gdb "reverse debugging"
  -- * set record full insn-number-max unlimited
  -- * continue, record
  -- * revert-next, reverse-step
  -- gdb server
  -- * gdbserver :666 build/bin/nvim 2> gdbserver.log
  -- * gdb build/bin/nvim -ex 'remote localhost:666'
  use { 'sakhnik/nvim-gdb' } -- TODO: fix https://github.com/sakhnik/nvim-gdb/issues/177
  --use { 'luukvbaal/nnn.nvim', config = function() require('nnn').setup() end, } --<l>n and :Np
  -- :Dirbuf, <CR>, gh (toggel hidden files), -, :w[rite], C-m on path to open dir in dirbuf
  use { 'elihunter173/dirbuf.nvim', config = function() require("dirbuf").setup { write_cmd = "DirbufSync -confirm" } end, }
  use { 'anuvyklack/hydra.nvim' } -- my_hydra.lua
  -- note visual mode gc,gb clash
  -- visual gc/gb, normal [count]gcc/gbc, gco/gcO/gcA
  use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end, }
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
  use { 'ThePrimeagen/harpoon' } -- <l> or ; [m|c|s]key=[j|k|l|u|i] mv|mc|mm, :CKey, :CCmd

  ---- telescope ----
  use { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } } --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- 1.65x speed of fzf
  -- Telescope gh issues author=windwp label=bug search=miscompilation
  use { 'nvim-telescope/telescope-github.nvim' } --Telescope gh issues|pull_request|gist|run
  -- <leader>fd file search by directory, <leader>fs forwardIntoDir searchstring
  --broken with https://github.com/princejoogie/dir-telescope.nvim/issues/6
  --use { 'princejoogie/dir-telescope.nvim', config = function() require('dir-telescope').setup({hidden = false,respect_gitignore = false,}) end, }
  ---- treesitter ----
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'mizlan/iswap.nvim' } --:Iswap, as mapping :ISwapWith
  --'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'

  ---- languages ----
  --use { 'neomake/neomake' } -- get useful comments for code semantics
  use { 'LnL7/vim-nix' } -- flakes highlighting: wait until nix converts their stuff to flakes
  use { 'ziglang/zig.vim' } -- :lua vim.api.nvim_set_var("zig_fmt_autosave", 0)
  ---- Organization
  use { 'jbyuki/venn.nvim' } --hydra: <l>v without: set ve=all,:VBox or press f,HJKL,set ve=
  use { 'mbbill/undotree' } -- :UndotreeToggle, rarely used (<l>u unmapped)
  -- As of now, which-key breaks terminals
  use { 'folke/which-key.nvim', config = function() require('which-key').setup() end, } -- :Telescope builtin.keymaps

  -- use { 'smjonas/inc-rename.nvim' } -- idea setup
  -- use { 'smjonas/live-command.nvim' } -- idea setup
  -- use { 'otavioschwanck/cool-substitute.nvim', config = function() require'cool-substitute'.setup{ setup_keybindings = true } end, }
  -- use { 'ThePrimeagen/git-worktree.nvim' } -- idea project setup
  -- use { 'nvim-telescope/telescope-dap.nvim', requires = { 'mfussenegger/nvim-dap' } } -- idea setup
  -- use { 'theHamsta/nvim-dap-virtual-text',  'rcarriga/nvim-dap-ui' } -- idea setup + comapre with harpoon approach
  -- Lua
  --use { 'bfredl/nvim-luadev' } --lua repl, setup mappings for execution
  --use { 'jbyuki/one-small-step-for-vimkind', requires = { 'mfussenegger/nvim-dap' } } -- lua debugging runtime, setup
  --<Plug>(Luadev-RunLine)  Execute the current line
  --<Plug>(Luadev-Run)      Operator to execute lua code over a movement or text object.
  --<Plug>(Luadev-RunWord)  Eval identifier under cursor, including table.attr
  --<Plug>(Luadev-Complete) in insert mode: complete (nested) global table fields
  --idea: find something like scrollbackedit from zellij for neovim terminal
  --idea: masterplan: Vim macro to lua function translation
  --  1. read current keybinding including inbuilds => refactor core keyevent handling in neoim (https://github.com/linty-org/key-menu.nvim/issues/10)
  --  2. track the mode, last action and read keys to lookup next action => or capture this in neovim without executing it
  -- related: use { 'linty-org/key-menu.nvim' } -- idea replace which-key once https://github.com/linty-org/key-menu.nvim/issues/10 is resolved

  --use { 'asbjornhaland/telescope-send-to-harpoon.nvim' } -- required: telescope,harpoon
  --use { 'LinArcX/telescope-command-palette.nvim' } -- necessary?
  --use { 'nvim-telescope/telescope-symbols.nvim' } --:lua require'telescope.builtin'.symbols{ sources = {'emoji', 'kaomoji', 'gitmoji'} }
  --use { '~/dev/git/lua/telescope-project.nvim' } -- idea fixit
  --use { 'nvim-telescope/telescope-project.nvim' } -- create,delete,find,search, w without opening, <l>pr => workspaces, then bare reposwor, then bare repos
  --use { '~/dev/git/nvimproj/telescope-project-scripts.nvim' } -- waiting for feedback from upstream
  -- files of telescope-project inside ~/.local/share/nvim/ telescope-project.nvim file to track workspaces not implemented yet
  --use { 'axkirillov/easypick.nvim' } -- custom telescope pickers from shell commands

  -- :DogeGenerate {doc_standard}
  -- use { 'kkoomen/vim-doge' }
  -- :Neogen [function/class/type]
  -- use { 'cshuaimin/ssr.nvim' }
  --use { 'danymat/neogen', config = function() require('neogen').setup {} end, requires = 'nvim-treesitter/nvim-treesitter', }
  -- use { 'booperlv/nvim-gomove' } -- moving blocks sidewarsd up,down etc
  --use { 'nvim-telescope/telescope-hop.nvim' } -- idea fix setup: no numbers are showing up
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
