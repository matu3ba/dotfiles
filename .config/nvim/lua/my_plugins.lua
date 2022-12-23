return {
  'marko-cerovac/material.nvim', --<l>ma
  -- TODO: publish the git worktree helper scripts
  { 'folke/which-key.nvim', lazy = true },
  { 'williamboman/mason.nvim', config = function() require("mason").setup() end, },

  { 'neovim/nvim-lspconfig' }, --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
  ---- completions ----
  -- C-x + C-n|p | C-f | C-k  buffer, filepaths, keywords
  -- C-x + C-l | C-s | C-t    lines, spell, thesaurus
  -- C-x + C-v | C-z | C-]    vim, stop, tags
  -- C-x + C-o                user function (omnifunction)
  -- C-x + C-u                user function (completefunc)
  -- C-x + C-d | C-i          macros, include paths
  { 'hrsh7th/nvim-cmp', branch = 'main' },
  { 'hrsh7th/cmp-nvim-lsp', branch = 'main' },
  -- { 'hrsh7th/cmp-path' } -- performance problems (no timeout etc)
  -- { 'hrsh7th/cmp-buffer' } -- broken: https://github.com/hrsh7th/cmp-buffer/issues/54
  { 'hrsh7th/cmp-cmdline', branch = 'main' }, -- completions for :e, /, buffer are broken

  -- default mappings: textobjects: ii, ai, goto: [i,]i
  -- no color support yet: https://github.com/echasnovski/mini.nvim/issues/99
  { 'echasnovski/mini.indentscope', config = function() require("mini.indentscope").setup({}) end, branch = 'main', lazy = true },
  -- ga no preview, gA preview
  { 'echasnovski/mini.align', config = function() require("mini.align").setup({}) end, branch = 'main', lazy = true },
  -- a,i main prefixes, an,in,al,il next last textobject, g[,g] movement
  { 'echasnovski/mini.ai', config = function() require("mini.ai").setup({}) end, branch = 'main', lazy = true },
  -- { 'echasnovski/mini.completion' } -- TODO: think how to configure nvim-cmp to use something else than C-n|p

  { 'tpope/vim-fugitive', lazy = true },
  --gitsigns: [c, ]c, <l>hs/hu,hS/hR,hp(review),hb(lame),hd(iff),hD(fndiff),htb(toggle line blame),htd(toggle deleted) :Gitsigns toggle_
  --{ 'lewis6991/gitsigns.nvim', branch = 'main', config = function() require('gitsigns').setup() end },
  { 'lewis6991/gitsigns.nvim', branch = 'main', lazy = true },
  --{ 'tpope/vim-fugitive' } -- idea try without, find plugin for in buffer interative rebasing
  --:DiffviewOpen, :DiffviewClose/tabclose, :DiffviewFileHistory
  { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim', lazy = true },
  -- idea { 'axieax/urlview.nvim' } -- :Telescope urlview
  --requires = { 'tpope/vim-repeat' },
  -- leap: s|S char1 char2 (<space>|<tab>)* label?
  -- leap: gs in all other windows on the tab page
  -- leap: enter repeates, tab reverses the motion
  -- (unused default breaks nvim-surround) s|S char1 char2 <space>? (<space>|<tab>)* label?
  -- -|_ char1 char2 <space>? (<space>|<tab>)* label?
  { 'ggandor/leap.nvim', branch = 'main', lazy = true }, -- repeat action not yet supported
  -- :Dirbuf, <CR>, gh (toggel hidden files), -, :w[rite], C-m on path to open dir in dirbuf
  { 'elihunter173/dirbuf.nvim', config = function() require("dirbuf").setup { write_cmd = "DirbufSync -confirm" } end, branch = 'main' },
  { 'anuvyklack/hydra.nvim' }, -- my_hydra.lua
  -- note visual mode gc,gb clash
  -- visual gc/gb, normal [count]gcc/gbc, gco/gcO/gcA
  { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end, },
  -- { 'nicwest/vim-camelsnek' } -- idea setup
  -- selection S' to put ' around selected text
  -- ysiw' for inner word with '
  -- ? support for ysiwf ?
  -- word -> ysiw' -> 'word'
  -- *word_another bla -> ysit<space>" -> "word_another"* bla
  -- (da da) ->(  ysa") -> ("da da")
  { 'kylechui/nvim-surround', config = function() require("nvim-surround").setup() end, branch = 'main' }, -- stylish
  -- gm, M to mark word/region, M delete word
  -- g!M matches only full word
  -- do stuff, r, e etc
  -- press M or C-b to finish editing record and go forward/backward
  -- keep pressing M or C-b to reapply changes in selection
  -- press <CR> to mark match at cursor ignored
  -- navigate without changing with C-j, C-k
  -- ga: change all occurences
  -- TODO handroll debugger control for gdb via server and pipe stuff to buffer
  -- TODO command to extract debug points out of gdb (visualize shoudl work fine)
  { 'ThePrimeagen/harpoon' }, -- <l> or ; [m|c|s]key=[j|k|l|u|i] mv|mc|mm, :CKey, :CCmd
  ---- telescope ----
  { 'nvim-telescope/telescope.nvim', requires = { { 'nvim-lua/popup.nvim' }, { 'nvim-lua/plenary.nvim' } } }, --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', branch = 'main' }, -- 1.65x speed of fzf
  -- Telescope gh issues author=windwp label=bug search=miscompilation
  { 'nvim-telescope/telescope-github.nvim' }, --Telescope gh issues|pull_request|gist|run
  -- <leader>fd file search by directory, <leader>fs forwardIntoDir searchstring
  --broken with https://github.com/princejoogie/dir-telescope.nvim/issues/6
  --{ 'princejoogie/dir-telescope.nvim', config = function() require('dir-telescope').setup({hidden = false,respect_gitignore = false,}) end, },
  ---- treesitter ----
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
  { 'mizlan/iswap.nvim' }, --:Iswap, as mapping :ISwapWith

  ---- languages ----
  --{ 'neomake/neomake' } -- get useful comments for code semantics
  { 'LnL7/vim-nix' }, -- flakes highlighting: wait until nix converts their stuff to flakes
  { 'ziglang/zig.vim' }, -- :lua vim.api.nvim_set_var("zig_fmt_autosave", 0)
  ---- Organization
  { 'jbyuki/venn.nvim', branch = 'main' }, --hydra: <l>v without: set ve=all,:VBox or press f,HJKL,set ve=
  { 'debugloop/telescope-undo.nvim', branch = 'main' }, -- browse via <C-n>,<C-p>, <C-CR> revert state, <CR> yank additions, <S-CR> yank deletions
  { 'mbbill/undotree' }, -- :UndotreeToggle, rarely used (<l>u unmapped)
  -- As of now, which-key breaks terminals
  { 'folke/which-key.nvim', config = function() require('which-key').setup() end, }, -- :Telescope builtin.keymaps

  -- lua hacking
  -- chrigieser/nvim-genghis convenience file operations in lua
  --spell: 'z=', 'zW', 'zg', 'zG', 'zw', 'zuW', 'zug', 'zuG', 'zuw'

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
  -- more severe issues with stability (editor becomes completely unresponsive) :-( )
  --{ 'sakhnik/nvim-gdb' } -- TODO: fix https://github.com/sakhnik/nvim-gdb/issues/177
}
