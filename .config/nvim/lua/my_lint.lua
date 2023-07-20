--! Dependency nvim-lint

local ok_lint, lint = pcall(require, 'lint')
if not ok_lint then return end

-- python3 -m pip install --user --upgrade pip
-- pip3 install -U --user ruff
-- pip3 install -U --user mypy

-- updating pip
-- pip list --outdated
-- pip freeze > req.txt
-- sed -i 's|==|>=|g' req.txt
-- pip3 install --user -r req.txt --upgrade

lint.linters_by_ft = {
  -- # ignore ruff lints for whole file (too long line)
  -- # ruff: noqa: E501 E701
  -- # ignore ruff lints with at end eof line:
  -- # noqa: F821
  -- # ignore mypy lints with at end eof line:
  -- # type: ignore
  -- older systems and installing libs: pip install pipx
  -- pipx install mypy
  -- pipx install ruff
  -- Converting to pipx might require to rm ~/.local/bin/deps
  -- fd -e py --max-depth=1 -x ruff check {}
  -- fd -e py --max-depth=1 -x ruff check --fix {}
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
-- E501: max line length
-- E701: Multiple statements on one line.
-- --line-length 150
ruff.args = {
  '--quiet',
  '--ignore',
  'E501,E701,E702',
  '-'
}

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function() lint.try_lint() end,
})
