require('nvim-treesitter.configs').setup {
  -- ensure_installed = 'maintained',
  ensure_installed = { 'bash', 'c', 'cpp', 'julia', 'python', 'rust', 'lua', 'typescript', 'vim', 'zig' },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  --incremental_selection = {
  --  enable = true,
  --  keymaps = {
  --    init_selection = "gnn",
  --    node_incremental = "grn",
  --    scope_incremental = "grc",
  --    node_decremental = "grm",
  --  },
  --},
  indent = {
    enable = true,
  },
  --set foldmethod=expr --respecting foldnestmax setting
  --set foldexpr=nvim_treesitter#foldexpr()
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = 1000,
  },
  --refactor = {
  --  highlight_definitions = { enable = true },
  --  highlight_current_scope = { enable = true },
  --  smart_rename = {
  --    enable = true,
  --    keymaps = {
  --      smart_rename = "grr",
  --    },
  --  },
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
