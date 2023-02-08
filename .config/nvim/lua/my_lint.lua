--! Dependency nvim-lint

local ok_lint, lint = pcall(require, 'lint')
if not ok_lint then
  return
end

lint.linters_by_ft = {
  python = {'mypy','ruff'}
}

local ruff = lint.linters.ruff
ruff.args = {
  '--quiet',
  '--line-length',
  '120',
  '-'
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function() lint.try_lint() end,
})
