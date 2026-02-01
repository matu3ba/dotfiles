--! Treesitter configurations
-- luacheck: globals vim
-- luacheck: no max line length

-- "Syntax highlighting is a waste of an information channel" by Hill Wayne
-- tldr; what to highlight should be switchable since colors have high
-- information density to detect patterns

--====ziggy
--====config

-- treesitter
-- gV node incremental selection, gS scope incremental selection

--- Remove externally installed broken treesitter parsers---
--- rm ~/.local/nvim/lib/nvim/parser/c.so
--- rm ~/.local/nvim/lib/nvim/parser/cpp.so
--- rm ~/.local/share/nvim/site/parser
--- rm ~/.local/share/nvim/lazy/nvim-treesitter/parser/

--- Show current infos :Inspect, :InspectTree

-- SHENNANIGAN DESIGN
-- * GENERAL
--   + https://github.com/neovim/neovim/issues/22426
--     - Rendering long lines is inefficient
--     - Injection queries are run too often
--   + https://github.com/tree-sitter/tree-sitter/issues/930#issuecomment-974399515
--     https://github.com/tree-sitter/tree-sitter/blob/master/docs/section-5-implementation.md#the-runtime
--     no docs on runtime including query performance and query cache etc
--     // The entries are sorted by the patterns' root symbols, and lookups use a
--     // binary search. This ensures that the cost of this initial lookup step
--     // scales logarithmically with the number of patterns in the query.
--     However this only mentions "initial lookup step" and not overall worst case
--     performance per pattern match or is unlucky formulated.

-- idea: https://jdhao.github.io/2020/11/15/nvim_text_objects/
--       and https://github.com/nvim-treesitter/nvim-treesitter-textobjects

-- --====custom_parser
-- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
-- parser_config.ziggy = {
--   install_info = {
--     url = 'https://github.com/kristoff-it/ziggy',
--     includes = { 'tree-sitter-ziggy/src' },
--     files = { 'tree-sitter-ziggy/src/parser.c' },
--     branch = 'main',
--     generate_requires_npm = false,
--     requires_generate_from_grammar = false,
--   },
--   filetype = 'ziggy',
-- }
-- like init.lua use
-- vim.filetype.add {
--   extension = {
--     ziggy = 'ziggy',
--   },
-- }

--====config
local has_ts, ts = pcall(require, 'nvim-treesitter')
if not has_ts then
  vim.print 'Please install nvim-treesitter/nvim-treesitter.'
  -- cargo install --locked tree-sitter-cli
  return
end
ts.setup {
  -- ensure_installed = 'maintained',
  -- ensure_installed = {
  --   'bash',
  --   'diff',
  --   'fish',
  --   'git_config',
  --   'git_rebase',
  --   'gitattributes',
  --   'gitignore',
  --   'json',
  --   'julia',
  --   'lua',
  --   'luadoc',
  --   'make',
  --   'markdown',
  --   'nix',
  --   'python',
  --   'rust',
  --   'toml',
  --   'typescript',
  --   'vim',
  --   'vimdoc',
  -- },
  -- 'c', 'cpp', zig

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    -- nvim gcc/c-family/c-common.cc from git://gcc.gnu.org/git/gcc.git
    -- freezes editor and configured clangd provides us with highlighting
    -- zig does not need treesitter for highlighting (zls also provides info)
    -- disable = { 'zig' },
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
    -- disable = { 'zig' }, -- slow, so opt-in
  },
  indent = {
    enable = true,
    disable = { 'c', 'cpp' }, -- broken
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

-- Disable until https://github.com/mizlan/iswap.nvim/issues/77 is resolved.
-- require('iswap').setup {}
