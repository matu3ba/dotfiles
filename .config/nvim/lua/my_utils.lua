local M = {}

--map('v', '<leader>p', [[lua require('my_utils').preserve("p")]], opts)
--does not work as expected, from https://vi.stackexchange.com/a/34495
M.preserve = function(arguments)
  local args = string.format('keepjumps keeppatterns execute %q', arguments)
  -- local original_cursor = vim.fn.winsaveview()
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local line = tup_rowcol[1]
  local col = tup_rowcol[2] -- 0 indexed => use +1
  vim.api.nvim_command(args)
  local lastline = vim.fn.line '$'
  -- vim.fn.winrestview(original_cursor)
  if line > lastline then
    line = lastline
  end
  vim.api.nvim_win_set_cursor(0, { line, col })
end

M.dump = function(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
  return ...
end

M.reload = function()
  for pkg, _ in pairs(package.loaded) do
    if
      pkg:match '^lazy'
      or pkg:match '^mapping'
      or pkg:match '^plugrc'
      or pkg:match '^ui'
      or pkg:match '^editor'
      or pkg:match '^plugins'
      or pkg:match '^syntax'
      or pkg:match '^terminal'
      or pkg:match '^utils'
    then
      package.loaded[pkg] = nil
    end
  end

  dofile(vim.env.MYVIMRC)
  vim.notify('Config reloaded!', vim.log.levels.INFO)
end

M.listpackages = function()
  for pkg, _ in pairs(package.loaded) do
    print(pkg)
    print '\n'
  end
end

M.reloadModule = function(module)
  for pkg, _ in pairs(package.loaded) do
    if pkg:match('^' .. module) then
      package.loaded[pkg] = nil
      require(pkg)
    end
  end
  vim.notify('Module ' .. module .. ' reloaded!', vim.log.levels.INFO)
end

return M
