--! Dependency free functions
local M = {}

M.IsWSL = function()
  local fp = assert(io.open("/proc/version", "rb"));
  local content = fp:read("*all")
  fp:close()
  local found_wsl = string.find(content, "microsoft")
  return found_wsl ~= nil
end

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

-- TODO understand lua print(vim.inspect(package.loaded, { depth = 1 }))
-- to unload commands, mappings + relevant plugin symbols
-- https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/15
M.reloadconfig = function()
  local luacache = (_G.__luacache or {}).cache
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

M.makeScratch = function(scratchpath)
  local buf = vim.api.nvim_create_buf(true, true) -- listed, scratch: nomodified, nomodeline
  vim.api.nvim_win_set_buf(0, buf)
end

-- M.makeFileScratch = function(filepath)
--   local uri = vim.uri_from_fname(filepath)
--   local bufnr = vim.uri_to_bufnr(uri)
--   vim.bo[bufnr].bufhidden = ""
--   vim.bo[bufnr].buflisted = true
--   vim.bo[bufnr].buftype = ""
--   vim.bo[bufnr].readonly = false
--   vim.bo[bufnr].swapfile = false
-- end

-- :ls! to list all bufs
-- TODO: store and load scratch/notes files
-- scratch -> notes (persistent)
-- make neovim instance
M.makeFileScratch = function(filepath)
--M.makeNamedScratch = function(filepath, scratchname)
  -- local bufs = vim.api.nvim_list_bufs()
  --for i, v in ipairs(bufs) do
  --  if(vim.api.nvim_buf_get_name(v) == "abspath_tocompare") then
  --    print("matching comparison")
  --  end
  --  print(k, ", ", v)
  --end
  local uri = vim.uri_from_fname(filepath)
  local bufnr = vim.uri_to_bufnr(uri)
  vim.bo[bufnr].bufhidden = ""
  vim.bo[bufnr].buflisted = true
  vim.bo[bufnr].buftype = ""
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].swapfile = false
  return true
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

--- Copy content to matching char into register
-- without match, a message is printed
-- @param backwards boolean if search is forwards or backwards
-- @param register register where content is copied to
_G.CopyMatchingChar = function(backwards, register)
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local crow = tup_rowcol[1]
  local ccol = tup_rowcol[2] -- 0 indexed => use +1
  local cchar = vim.api.nvim_get_current_line():sub(ccol + 1, ccol + 1)
  local matchchar = {
    ['('] = ')',
    [')'] = '(',
    ['{'] = '}',
    ['}'] = '{',
    ['['] = ']',
    [']'] = '[',
    ['<'] = '>',
    ['>'] = '<',
    ['"'] = '"',
    ["'"] = "'",
    ['|'] = '|',
    ['`'] = '`',
    ['/'] = '/',
    ['\\'] = '\\',
  }
  -- note searchpos: stopline only works forwards
  -- => flag 'b' is not using starting line
  local tup_search
  if backwards == false then
    tup_search = vim.fn.searchpos(matchchar[cchar], 'nz', crow + 1) -- +1 to search until next line?
  else
    tup_search = vim.fn.searchpos(matchchar[cchar], 'bnz') -- +1 to search until next line?
  end
  local srow = tup_search[1]
  local scol = tup_search[2]
  if srow == 0 and scol == 0 and backwards == false then
    print 'no matching forward character'
    return
  end
  if (srow == 0 and scol == 0 and backwards == true) or srow ~= crow or (backwards == true and ccol < scol) then
    print 'no matching backwards character'
    return
  end
  local copytext
  if backwards == false then
    copytext = vim.api.nvim_get_current_line():sub(ccol + 1, scol)
    print(string.format([[%s %s:%s]], [[write -> into]], register, copytext))
  else
    copytext = vim.api.nvim_get_current_line():sub(scol, ccol + 1)
    print(string.format([[%s %s:%s]], [[write <- into]], register, copytext))
  end
  vim.fn.setreg(register, copytext)
end
---- copy forward/backwards until first occurence of same symbol
-- map('n', '-', ':lua require("my_utils").CopyMatchingChar(false, [[""]])<CR>', opts)
-- map('n', '_', ':lua require("my_utils").CopyMatchingChar(true, [[""]])<CR>', opts)

return M
