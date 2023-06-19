--! Dependency nvim-lint

local ok_lint, lint = pcall(require, 'lint')
if not ok_lint then return end

lint.linters_by_ft = {
  -- # ignore ruff lints for whole file (too long line)
  -- # ruff: noqa: E501
  -- # ignore ruff lints with at end eof line:
  -- # noqa: F821
  -- # ignore mypy lints with at end eof line:
  -- # type: ignore
  -- pipx install mypy
  -- pipx install ruff
  -- Converting to pipx might require to rm ~/.local/bin/deps
  python = { 'mypy', 'ruff' },
  -- clang14 introduced:
  -- // NOLINTBEGIN
  -- // NOLINTEND
  -- // NOLINTBEGIN(errorclass)
  -- somecode // NOLINT
  cpp = { 'clangtidy' },
  -- luacheck: push ignore
  -- luacheck: pop ignore
  -- luacheck: globals vim
  -- luacheck: no max line length
  -- See also https://github.com/LuaLS/lua-language-server/wiki/Annotations
  lua = { 'luacheck' },
}

local ruff = lint.linters.ruff
ruff.args = {
  '--quiet',
  '--ignore', -- '--line-length',
  'E501', -- '150',
  '-'
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function() lint.try_lint() end,
})
