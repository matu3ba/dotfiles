--! Dependency free functions
local M = {}

M.appDateLog = function(content)
  local current_date = os.date("%Y%m%d") -- year month day according to strftime
  local fp = assert(io.open( (current_date .. ".log"), "a"))
  fp:write(content)
  fp:close()
end

-- must be global, because keybindings dont accept lua functions yet
M.getCurrLinePlNL = function()
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  local curline = vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]
  return curline .. "\n"
end

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

M.reloadconfig = function()
  local luacache = (_G.__luacache or {}).cache
  -- TODO unload commands, mappings + ?symbols?
  for pkg, _ in pairs(package.loaded) do
    if pkg:match '^my_.+'
    then
      print(pkg)
      package.loaded[pkg] = nil
      if luacache then
        lucache[pkg] = nil
      end
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify('Config reloaded!', vim.log.levels.INFO)
end

M.makeScratch = function()
  vim.api.nvim_command('enew') -- equivalent to :enew
  vim.bo[0].buftype="nofile" -- set the current buffer's (buffer 0) buftype to nofile
  vim.bo[0].bufhidden="hide"
  vim.bo[0].swapfile=false
end

-- ###### Notes for terminal stuff ######
-- vim.api.nvim_command('botright split new') -- split a new window (no lua api yet)
-- vim.api.nvim_win_set_height(0, 30) -- set the window height
-- local win_handle = vim.api.nvim_tabpage_get_win(0) -- get the window handler
-- local buf_handle = vim.api.nvim_win_get_buf(0) -- get the buffer handler
-- jobID = vim.api.nvim_call_function("termopen", {"$SHELL"})
-- vim.api.nvim_buf_set_option(buf_handle, 'modifiable', true)
-- vim.api.nvim_buf_set_lines(buf_handle, 0, 0, true, {"ls"})
-- nvim_get_channel_info(&channel).pty

-- vim.env does not contain all environment variables, for example EDITOR is missing
-- vim.env.CMDLOG = 'bar'
-- print(vim.env.CMDLOG) -- called from subshells, however works

M.printPairsToTmp = function(table)
  local fp = assert(io.open("/tmp/tmpfile", "a"))
  for key,value in pairs(table) do
    fp:write(key)
    fp:write(", ")
    fp:write(value)
    fp:write("\n")
  end
  fp:close()
end

M.printIpairsToTmp = function(table)
  local fp = assert(io.open("/tmp/tmpfile", "a"))
  for index,value in ipairs(table) do
    fp:write(index)
    fp:write(", ")
    fp:write(tostring(value))
    fp:write("\n")
  end
  fp:close()
end

M.Print = function(v)
  print(vim.inspect(v))
  return v
end

M.listpackages = function()
  -- buf_open_scratch is missing in vim.api
  -- local bufnr = vim.api.nvim_create_buf(true, true)
  -- print(bufnr)
  -- vim.api.nvim_open_win(bufnr, 0, win_opts)
  vim.api.nvim_command('enew')
  local contents = {}
  for pkg, _ in pairs(package.loaded) do
    table.insert(contents, pkg)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, true, contents)
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
