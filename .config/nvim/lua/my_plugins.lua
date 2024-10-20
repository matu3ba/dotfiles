--! Plugin table used by lazy.nvim
-- luacheck: globals vim
-- luacheck: no max line length
-- idea: create dynlibs and nvim API https://git.mzte.de/LordMZTE/znvim
return {
  -- lazy local dev: ~/projects
  -- clean cache:
  -- rm -fr $HOME/.cache/nvim/lazy
  -- rm -fr $HOME/.local/share/nvim/lazy
  --==Revert a plugin
  --:Lazy log pluginname
  --cursor on top of commit hash, then press r
  --See init.lua for snapshot generation: :BrowseSnapshots
  --Copy lazy-lock from snapshots and restore
  --  :e vim.fn.stdpath('config') .. '/lazy-lock.json'
  --  :e vim.fn.stdpath('data') .. '/lazy_snapshot'
  --  cp "$HOME/.local/share/nvim/FILE" "$HOME/.config/nvim/lazy-lock.json"
  --  :Lazy restore lazy-lock.json
  --Or for only 1 plugin from the lazy-lock: :Lazy restore pluginname
  -- { 'https://mzte.de/git/LordMZTE/znvim' },
  -- Debug plugins startuptime via: nvim -V1 --startuptime FILE
  -- To find which plugins to disable, use :verbose au BufEnter
  { 'nvim-lua/plenary.nvim' },
  {
    'marko-cerovac/material.nvim',
    priority = 1000, --<l>ma
    config = function()
      require('material').setup {
        -- workaround https://github.com/marko-cerovac/material.nvim/issues/181
        disable = { colored_cursor = true },
      }
      vim.cmd.colorscheme 'material'
    end,
  },
  {
    'williamboman/mason.nvim',
    config = function() require('mason').setup() end,
  }, ---=none
  --==completions
  -- C-x + C-n|p | C-f | C-k  buffer, filepaths, keywords
  -- C-x + C-l | C-s | C-t    lines, spell, thesaurus
  -- C-x + C-v | C-z | C-]    vim, stop, tags
  -- C-x + C-o                user function (omnifunction)
  -- C-x + C-u                user function (completefunc)
  -- C-x + C-d | C-i          macros, include paths
  -- Note: omnifunction or completefunc is typically used by plugin, so may not
  -- be available to user (here it is not due to usage of nvim-cmp).

  -- { 'rafcamlet/nvim-luapad' }, -- lua dev
  { 'folke/neodev.nvim', opts = {} }, -- lua dev

  { --==LSP
    { 'neovim/nvim-lspconfig' }, --:sh, gd,gi,gs,gr,K,<l>ca,<l>cd,<l>rf,[e,]e, UNUSED: <l>wa/wr/wl/q/f (workspace folders, loclist, formatting)
    -- Autocompletion
    { 'hrsh7th/nvim-cmp' }, -- Autocompletion plugin
    { 'hrsh7th/cmp-nvim-lsp' }, -- LSP source for nvim-cmp
    -- { 'L3MON4D3/LuaSnip' }, -- Snippets plugin
    -- { 'saadparwaiz1/cmp_luasnip' }, -- Snippets source for nvim-cmp
    -- Optional
    {
      'williamboman/mason.nvim',
      build = function() pcall(vim.cmd, 'MasonUpdate') end,
    },
    -- {'williamboman/mason-lspconfig.nvim'}, -- Optional
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lua' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-nvim-lsp-signature-help' },
  },

  --==cmd line completions (breaks cmdline visuals for :echo $<C-d>)
  { 'hrsh7th/cmp-cmdline' }, -- completions for :e, /

  --==macros
  -- { 'ecthelionvi/NeoComposer.nvim', dependencies = { 'kkharji/sqlite.lua' } }, -- idea for macros
  -- { "chrisgrieser/nvim-recorder" },
  -- think about yoinking the macro history parts
  -- { "AckslD/nvim-neoclip.lua" }, -- setup for macro history + storage (sqlite for persistent storage)?
  {
    'tamton-aquib/keys.nvim',
    config = function() require('keys').setup {} end,
  }, -- :KeysToggle

  -- default mappings: textobjects: ii, ai, goto: [i,]i
  -- no color support yet: https://github.com/echasnovski/mini.nvim/issues/99
  {
    'echasnovski/mini.indentscope',
    version = false,
    config = function() require('mini.indentscope').setup {} end,
  },

  -- :lua vim.print(require('nvim-navic').is_available(0))
  -- :lua vim.print(require('nvim-navic').get_data())
  { 'SmiteshP/nvim-navic', requires = 'neovim/nvim-lspconfig' },

  -- idea, if annoying: lazy loads + mini config
  -- https://github.com/nikfp/nvim-config/blob/d4ae8c4f5cfe21df2f2146a9769db76490b7e76c/lua/plugins/lspconfig.lua#L11
  -- https://github.com/nikfp/nvim-config/blob/d4ae8c4f5cfe21df2f2146a9769db76490b7e76c/lua/plugins/lspconfig.lua#L232-L260
  -- ga no preview, gA preview
  {
    'echasnovski/mini.align',
    version = false,
    config = function() require('mini.align').setup {} end,
  },
  -- a,i main prefixes, an,in,al,il next last textobject, g[,g] movement
  {
    'echasnovski/mini.ai',
    version = false,
    config = function() require('mini.ai').setup {} end,
  },
  -- [] mappings for buffer, komment, x conflict, diagnostics, file, indent, jump, location,
  -- location, oldfile, quickfix, treesitter, undo, window, yank
  -- [c,]c, used for diff
  {
    -- TODO debug problem
    'echasnovski/mini.bracketed',
    version = false,
    config = function()
      require('mini.bracketed').setup {
        comment = { suffix = 'v' }, -- verbose comment
        -- treesitter = { options = { add_to_jumplist = true } },
      }
    end,
  },
  -- usage in my_hydra.lua
  {
    'echasnovski/mini.move',
    version = false,
  },
  {
    'echasnovski/mini.operators',
    version = false,
  },
  -- { "echasnovski/mini.completion", version = false } -- idea: think how to configure nvim-cmp to use something else than C-n|p

  -- :Neogit
  -- TODO :Neogit diffsplit
  -- :Neogit pull, push, commit
  -- TODO faster rewrite of commit msg
  -- TODO faster squashing of message
  -- leader gs,gc,gp, q to close
  {
    'NeogitOrg/neogit',
    config = function()
      require('neogit').setup {
        filewatcher = {
          enabled = true,
        },
        disable_line_numbers = true,
        auto_refresh = false,
        console_timeout = 2000,
        auto_show_console = true,
      }
    end,
  },

  -- The alternative would be to use https://github.com/git/git/blob/master/Documentation/mergetools/vimdiff.txt
  -- as shown here https://gist.github.com/karenyyng/f19ff75c60f18b4b8149

  --gitsigns: [c, ]c, <l>hs/hu,hS/hR,hp(review),hb(lame),hd(iff),hD(fndiff),htb(toggle line blame),htd(toggle deleted) :Gitsigns toggle
  -- :Gitsigns show @~1
  {
    'lewis6991/gitsigns.nvim',
    -- initialized in .config/nvim/lua/my_gitsign.lua
    -- config = function() require('gitsigns').setup{} end,
  },
  --:DiffviewOpen, :DiffviewClose/tabclose, :DiffviewFileHistory
  -- USAGE
  --:DiffviewOpen origin/HEAD...HEAD --imply-local
  --:DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges
  --:DiffviewFileHistory -g --range=stash
  -- https://github.com/sindrets/diffview.nvim/blob/main/USAGE.md
  -- np, nextprev file tab,s-tab cycle
  -- cycle through diffs for modified files and git rev
  { 'sindrets/diffview.nvim' },
  -- idea { "axieax/urlview.nvim" } -- :Telescope urlview
  --requires = { "tpope/vim-repeat" },
  -- leap: s|S char1 char2 (<space>|<tab>)* label?
  -- leap: gs in all other windows on the tab page
  -- leap: enter repeates, tab reverses the motion
  -- (unused default breaks nvim-surround) s|S char1 char2 <space>? (<space>|<tab>)* label?
  -- -|_ char1 char2 <space>? (<space>|<tab>)* label?
  { 'ggandor/leap.nvim' }, -- repeat action not yet supported
  -- Remote editing
  -- nvim oil-ssh://[username@]hostname[:port]/[path]
  -- g? help, <CR>|C-s|C-h select +[vsplit|split, C-p preview, C-c close, C-l refresh,
  -- - parent, _ open cwd, ` cd, ~ tcd, g. toggle hidden
  { 'stevearc/oil.nvim' }, -- my_oil.lua
  -- fn overview window with jumps etc
  { 'stevearc/aerial.nvim' },
  { 'nvimtools/hydra.nvim' }, -- my_hydra.lua
  -- crs coerce to snake_case
  -- crm MixedCase = PascalCase
  -- crc camelCase
  -- cru UPPER_CASE cru
  -- cr- dash-case
  -- cr. dot.case
  -- missing handling of custom user prefixes for: m_MemberVar, eMember, sStruct
  { 'tpope/vim-abolish' }, -- { 'text-case.nvim' },
  { 'kylechui/nvim-surround' },
  {
    'NvChad/nvim-colorizer.lua',
    config = function() require('colorizer').setup() end,
  },
  --==taskrunner
  { 'stevearc/overseer.nvim', opts = {}, dev = false },
  -- { 'monaqa/dial.nvim' }, --idea
  -- { 'andymass/vim-matchup' }, --idea
  -- gm, M to mark word/region, M delete word
  -- g!M matches only full word
  -- do stuff, r, e etc
  -- press M or C-b to finish editing record and go forward/backward
  -- keep pressing M or C-b to reapply changes in selection
  -- press <CR> to mark match at cursor ignored
  -- navigate without changing with C-j, C-k
  -- ga: change all occurences
  -- idea handroll debugger control for gdb via server and pipe stuff to buffer
  -- idea command to extract debug points out of gdb (visualize should work fine)
  -- buffer manipulation + project search
  --==bufferactions
  -- blockers of harpoon2 mentioned in my_harpoon.lua
  -- { 'ThePrimeagen/harpoon', branch = 'harpoon2', config = function() require('nvim-surround').setup() end, },
  { 'matu3ba/harpoon', dev = false }, -- <l> or ; [m|c|s]key=[j|k|l|u|i] mv|mc|mm, :CKey, :CCmd
  -- { 'ThePrimeagen/harpoon' }, -- <l> or ; [m|c|s]key=[j|k|l|u|i] mv|mc|mm, :CKey, :CCmd
  -- use instead track.nvim?
  { 'matu3ba/libbuf.nvim', dev = true },
  -- any benchmark against nvim-telescope/telescope-fzf-native.nvim ?
  -- any way to place results in buffer?
  -- git clone https://github.com/jake-stewart/jfind && cd jfind && cmake -S . -B build && cd build && make -j$(nproc) && sudo make install
  -- ctrl-e, ctrl-a, ctrl-w, ctrl-f, ctrl-b for editing navigation, ctrl-p and ctrl-n for history.

  --==finder
  { 'jake-stewart/jfind.nvim', branch = '2.0' },
  -- think about design to resolve https://github.com/nvim-telescope/telescope.nvim/issues/647
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { { 'nvim-lua/popup.nvim', lazy = false } },
  }, --<l>tb/ff/gf/rg/th/pr/(deactivated)z
  { 'natecraddock/telescope-zf-native.nvim', lazy = false }, -- simpler algorithm for matching
  -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = false }, -- 1.65x speed of fzf
  -- Telescope gh issues author=windwp label=bug search=miscompilation
  { 'nvim-telescope/telescope-github.nvim' }, --Telescope gh issues|pull_request|gist|run
  -- <leader>fd file search by directory, <leader>fs forwardIntoDir searchstring
  --broken with https://github.com/princejoogie/dir-telescope.nvim/issues/6
  --{ "princejoogie/dir-telescope.nvim", config = function() require("dir-telescope").setup({hidden = false,respect_gitignore = false,}) end, },
  --==languages
  { 'mfussenegger/nvim-lint' }, -- configuration in my_lint.lua
  --{ "neomake/neomake" } -- get useful comments for code semantics
  -- { 'LnL7/vim-nix' }, -- flakes highlighting: wait until nix converts their stuff to flakes
  { 'ziglang/zig.vim' }, -- :lua vim.api.nvim_set_var("zig_fmt_autosave", 0)
  --==Organization
  -- ideas
  -- - ascii boxing
  -- - dot repetition
  -- - mini.move box movements https://github.com/echasnovski/mini.nvim/issues/838
  -- * ascii mode, see https://github.com/jbyuki/venn.nvim/issues/27
  -- * inline text spacing adjustments
  -- hydra venn extended: <l>ve
  -- hydra venn ascii: <l>va
  -- set ve=all,:VBox or press f,HJKL,set ve=
  { 'jbyuki/ntangle.nvim' },
  -- more functionality + tutorial
  -- https://www.baeldung.com/linux/vim-drawit-ascii-diagrams
  { 'jbyuki/venn.nvim', dev = true },
  -- idea { 'simnalamburt/vim-mundo' } to search undotree
  { 'mbbill/undotree' }, -- :UndotreeToggle, rarely used (<l>u unmapped)
  {
    'folke/which-key.nvim',
    config = function() require('which-key').setup() end,
  }, -- :Telescope builtin.keymaps

  -- markdown live preview via :Glow[!] [path]
  {
    'ellisonleao/glow.nvim',
    config = function() require('glow').setup() end,
  },
  -- jupyter and markdown live preview, idea
  -- https://github.com/kiyoon/jupynium.nvim
  -- https://github.com/tamton-aquib/neorg-jupyter

  -- open files from a neovim terminal buffer in your current neovim instance instead of a nested one.
  -- reuse some lua socket code?
  -- https://github.com/willothy/flatten.nvim

  -- { 'registers.nvim' },

  -- remote work without sshfs and vanilla editor: chipsenkbeil/distant.nvim

  -- lua hacking
  -- chrigieser/nvim-genghis convenience file operations in lua

  --'nvim-telescope/telescope-dap.nvim',
  { 'rcarriga/nvim-dap-ui' },
  { 'mfussenegger/nvim-dap' },
  { 'theHamsta/nvim-dap-virtual-text' },
  -- nvim-dap
  -- nvim-dap-ui
  -- nvim-dap-virtual-text
  -- :GdbStart gdb -tui exec, :GdbStart gdb -tui --args exec arg1 ..,
  -- :GdbStart gdb -tui -x SCRIPT exec
  -- :Gdb command
  -- <f4>   Until                        (`:GdbUntil`)
  -- <f5>   Continue                     (`:GdbContinue`)
  -- <f6>   Reverse-Next                 (`:idea`), idea
  -- <f7>   Reverse-Step                 (`:idea`), idea
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
  -- idea: build your own mouse hover? (use f9 to print locals instead of auto)
  -- idea: scratch window for gdb history, awaiting response https://github.com/sakhnik/nvim-gdb/issues/177
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
  --{ 'sakhnik/nvim-gdb' } -- idea: fix https://github.com/sakhnik/nvim-gdb/issues/177

  --{ "glepnir/mutchar.nvim" }, idea setup
  -- doesnt work for me
  -- { "chomosuke/term-edit.nvim", lazy = false, version = "1.*" },
  -- { 'debugloop/telescope-undo.nvim' }, -- browse via <C-n>,<C-p>, <C-CR> revert state, <CR> yank additions, <S-CR> yank deletions

  -- commonly known JSON file formats: schemastore.nvim
  -- toggleterm.nvim

  -- nvim-treesitter
  -- nvim-treesitter-context
  -- nvim-treesitter-textobjects
  -- nvim-treesitter-textsubjects
  --==treesitter
  -- replacement without perf issues for context.vim would be great
  -- { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  -- { 'mizlan/iswap.nvim' }, --:Iswap, as mapping :ISwapWith
  -- block-wise movement and file-local replacements
  -- { 'nvim-treesitter/nvim-treesitter-refactor' },

  -- non-treesitter functionality unnecessary since nvim 0.10
  -- { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end },
  -- deprecated since nvim 0.10
  -- { 'ojroques/nvim-osc52', config = function() require('osc52').setup() end }, ---=key

  -- idea https://phelipetls.github.io/posts/async-make-in-nvim-with-lua/
  -- https://stackoverflow.com/questions/60866833/vim-compiling-a-c-program-and-displaying-the-output-in-a-tab
  -- try https://github.com/cipharius/kakoune-arcan
  -- idea https://super-cress-98d.notion.site/Run-zig-test-in-neovim-cde72b0634b449bc815211c6ca1032a4
  -- idea keybindings for sending to terminal to gdb

  -- telescope-dap.nvim
  -- telescope-symbols.nvim
  -- telescope-ui-select.nvim
  -- text-case.nvim
}

--fugitive <leader> [gs|g2|g3|p2|p3]
-- TODO best shortcuts and brief usage
-- 1. :Git, =(toggle),-(),o(),v()
-- 2. reach the last commit that has touched the current file :Gedit !.
-- 3. :Gvdiffsplit!
-- goto conflict [c, ]c
-- On rebase file (mid, buffer has no number): :diffget left(2), right(3) [from git rebase 2] on branch 3
-- On left file (2): :diffput filename to put current se(le)ction into rebase file, otherwise use the right one(3) + vice versa
-- Faster one without selection: dp (diffput), do (diffget) does only work in 2 file diffs
-- Once done: C-w,C-o, :GWrite, :Git commit
-- SHENNANIGAN: ls! still shows hidden buffers
-- see also https://jeancharles.quillet.org/posts/2022-03-02-Practical-introduction-to-fugitive.html
-- { 'tpope/vim-fugitive' },