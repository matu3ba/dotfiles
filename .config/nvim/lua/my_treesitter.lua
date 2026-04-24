--! Treesitter configurations
-- luacheck: globals vim
-- luacheck: no max line length

-- "Syntax highlighting is a waste of an information channel" by Hill Wayne
-- tldr; what to highlight should be switchable since colors have high
-- information density to detect patterns

-- setup
-- 1 install tree-sitter-cli
--   * cargo install --locked tree-sitter-cli
-- 2 :TSInstall lang

--====ziggy
--====config

-- treesitter
-- gV node incremental selection, gS scope incremental selection
-- * not sure if that still works or not

--- Remove externally installed broken treesitter parsers---
--- rm ~/.local/nvim/lib/nvim/parser/c.so
--- rm ~/.local/nvim/lib/nvim/parser/cpp.so
--- rm ~/.local/share/nvim/site/parser
--- rm ~/.local/share/nvim/lazy/nvim-treesitter/parser/

--- Show current infos :Inspect, :InspectTree

-- SHENANIGAN DESIGN
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
