-- TODO how to pcall nvim-treesitter.configs ?
require('nvim-treesitter.configs').setup {
  -- ensure_installed = 'maintained',
  ensure_installed = { 'bash', 'c', 'cpp', 'julia', 'lua', 'python', 'rust', 'typescript', 'vim', 'vimdoc', 'zig' },
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    -- nvim gcc/c-family/c-common.cc from git://gcc.gnu.org/git/gcc.git
    -- freezes editor and configured clangd provides us with highlighting
    disable = { 'c', 'cpp', 'python', 'zig' },
  },
  -- Note, that vib also works for blocks (symbols might be desirable)
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<leader>vs',
      node_decremental = 'gsN',
      node_incremental = 'gsn',
      scope_incremental = 'gss',
    },
  },
  indent = {
    enable = true,
    disable = { 'cpp', 'python', 'zig' }, -- broken
  },
  --set foldmethod=expr --respecting foldnestmax setting
  --set foldexpr=nvim_treesitter#foldexpr()
  -- rainbow = {
  --   enable = true,
  --   extended_mode = true,
  --   max_file_lines = 10000,
  -- },
  -- context? if yes: <leader>vj for visual jump
  --refactor = {
  --  highlight_definitions = { enable = true },
  --  highlight_current_scope = { enable = true },
  --  smart_rename = {
  --    enable = true,
  --    keymaps = {
  --      smart_rename = "grr",
  --    },
  --  },
  --  configured in mini.bracketed
  --  navigation = {
  --    enable = true,
  --    keymaps = {
  --      goto_definition = "gnd",
  --      list_definitions = "gnD",
  --      list_definitions_toc = "gO",
  --      goto_next_usage = "<a-*>",
  --      goto_previous_usage = "<a-#>",
  --    },
  --  },
  --},
  --playground = {
  --  enable = true,
  --  disable = {},
  --  updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
  --  persist_queries = false -- Whether the query persists across vim sessions
  --},
  --query_linter = {
  --  enable = true,
  --  use_virtual_text = true,
  --  lint_events = {"BufWrite", "CursorHold"},
  --},
}
require('iswap').setup {}
