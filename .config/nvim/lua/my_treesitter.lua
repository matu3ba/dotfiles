--! Treesitter configurations
-- luacheck: globals vim
-- luacheck: no max line length

--====ziggy
--====config

-- treesitter
-- gV node incremental selection, gS scope incremental selection

--- Remove externally installed broken treesitter parsers---
--- rm ~/.local/nvim/lib/nvim/parser/c.so
--- rm ~/.local/nvim/lib/nvim/parser/cpp.so

--- Show current infos :Inspect, :InspectTree

-- SHENNANIGAN DESIGN
-- * GENERAL
--   + https://github.com/neovim/neovim/issues/22426
--   + https://github.com/tree-sitter/tree-sitter/issues/930#issuecomment-974399515
--     https://github.com/tree-sitter/tree-sitter/blob/master/docs/section-5-implementation.md#the-runtime
--     no docs on runtime including query performance and query cache etc
--     // The entries are sorted by the patterns' root symbols, and lookups use a
--     // binary search. This ensures that the cost of this initial lookup step
--     // scales logarithmically with the number of patterns in the query.
--     However this only mentions "initial lookup step" and not overall worst case
--     performance per pattern match or is unlucky formulated.
-- * NEOVIM
--   + treesitter can not be disabled: if it is installed, it will be loaded and
--   throw errors.
--   + pcall nvim-treesitter.configs still not supported
--   + treesitter languages may require: cargo install tree-sitter-cli
--   + TODO config: add missing pcalls/checks in treesitter and telescope-fzf-native
--   + require 'my_treesitter' -- startup time (time nvim +q) before 0.15s, after 0.165s, ubsan 2.6s

-- idea: https://jdhao.github.io/2020/11/15/nvim_text_objects/
--       and https://github.com/nvim-treesitter/nvim-treesitter-textobjects

--====ziggy
local parser_config = require('nvim-treesitter.parsers').get_parser_configs()

parser_config.ziggy = {
  install_info = {
    url = 'https://github.com/kristoff-it/ziggy',
    includes = { 'tree-sitter-ziggy/src' },
    files = { 'tree-sitter-ziggy/src/parser.c' },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'ziggy',
}

parser_config.ziggy_schema = {
  install_info = {
    url = 'https://github.com/kristoff-it/ziggy',
    files = { 'tree-sitter-ziggy-schema/src/parser.c' },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'ziggy-schema',
}

parser_config.supermd = {
  install_info = {
    url = 'https://github.com/kristoff-it/supermd',
    includes = { 'tree-sitter/supermd/src' },
    files = {
      'tree-sitter/supermd/src/parser.c',
      'tree-sitter/supermd/src/scanner.c',
    },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'supermd',
}

parser_config.supermd_inline = {
  install_info = {
    url = 'https://github.com/kristoff-it/supermd',
    includes = { 'tree-sitter/supermd-inline/src' },
    files = {
      'tree-sitter/supermd-inline/src/parser.c',
      'tree-sitter/supermd-inline/src/scanner.c',
    },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'supermd_inline',
}

parser_config.superhtml = {
  install_info = {
    url = 'https://github.com/kristoff-it/superhtml',
    includes = { 'tree-sitter-superhtml/src' },
    files = {
      'tree-sitter-superhtml/src/parser.c',
      'tree-sitter-superhtml/src/scanner.c',
    },
    branch = 'main',
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = 'superhtml',
}

--====config
require('nvim-treesitter.configs').setup {
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
    -- disable = { 'python', 'zig' }, -- broken
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
