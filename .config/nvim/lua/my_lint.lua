--! Dependency nvim-lint

local ok_lint, lint = pcall(require, 'lint')
if not ok_lint then return end

-- python3 -m pip install --user --upgrade pip
-- pip3 install -U --user ruff
-- pip3 install -U --user mypy
-- distropkg install python[3[x]-[pexpect|ruff|mypy]

-- updating pip
-- pip list --outdated
-- pip freeze > req.txt
-- sed -i 's|==|>=|g' req.txt
-- pip3 install --user -r req.txt --upgrade

-- idea codespell
-- https://sean.fish/x/blog/codespell-ignorelists-neovim/

lint.linters_by_ft = {
  -- # ignore ruff lints for whole file (too long line)
  -- # ruff: noqa: E501 E701
  -- # ignore ruff lints with at end eof line:
  -- # noqa: F821
  -- # ignore mypy lints with at end eof line:
  -- # type: ignore
  -- older systems and installing libs: pip install pipx
  -- To adjust system PATH, use python -m pipx ensurepath
  -- pipx install mypy
  -- pipx install ruff
  -- Converting to pipx might require to rm ~/.local/bin/deps
  -- fd -e py --max-depth=1 -x ruff check {}
  -- fd -e py --max-depth=1 -x ruff check --fix {}
  python = { 'mypy', 'ruff' },
  -- TODO clangd ignore lsp msg
  -- clang14 introduced:
  -- // NOLINTBEGIN
  -- // NOLINTEND
  -- // NOLINTBEGIN(errorclass)
  -- somecode // NOLINT
  c = { 'clangtidy' },
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
  '-',
}

-- clang-tidy -checks='bugprone-*,cert-*,clang-analyzer-*,cppcoreguidelines-*,hicpp-*' file.c -- [clang[++]|gcc|g++]-flags
-- -hicpp occasionally must be disabled.
-- misc-* opinionated
-- modernize-* bad for C interop (use 0 instead of nullptr to interop with C)
-- performance-* depends
-- portability-* depends
-- readability-* opinionated

-- # Checks
-- CHECKS="clang-*,cppcoreguidelines-*,modernize-*,performance-*,-clang-diagnostic-old-style-cast,-clang-diagnostic-sign-conversion,\
-- -modernize-use-auto,-cppcoreguidelines-special-member-functions,-cppcoreguidelines-pro-bounds-pointer-arithmetic,-cppcoreguidelines-pro-bounds-constant-array-index,\
-- -clang-diagnostic-conversion,-cppcoreguidelines-pro-bounds-array-to-pointer-decay,-cppcoreguidelines-pro-type-cstyle-cast,-clang-diagnostic-missing-variable-declarations,\
-- -clang-diagnostic-documentation-unknown-command,-clang-diagnostic-covered-switch-default"
--
-- # Warnings (from qtcreator - options - c++ - code model - clang)
-- WARN="-Weverything -Wno-c++98-compat -Wno-c++98-compat-pedantic -Wno-unused-macros -Wno-newline-eof -Wno-exit-time-destructors -Wno-global-constructors \
-- -Wno-gnu-zero-variadic-macro-arguments -Wno-documentation -Wno-shadow -Wno-switch-enum -Wno-missing-prototypes -Wno-used-but-marked-unused \
-- -Wno-unknown-pragmas -Wno-unused-parameter"
--
-- clang-tidy \
--     -checks="$CHECKS" \

-- local clangtidy = lint.linters.clangtidy
-- clangtidy.args = {
--   '--quiet',
-- }

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  callback = function() lint.try_lint() end,
})
