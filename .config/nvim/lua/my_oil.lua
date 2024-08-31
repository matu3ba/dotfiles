-- luacheck: globals vim
-- luacheck: no max line length
local M = {}
local has_oil, oil = pcall(require, 'oil')
if not has_oil then return end

oil.setup { view_options = { show_hidden = true } }

M.pwshExec = function()
  local entry = oil.get_cursor_entry()
  if not entry then return '' end
  return '.\\' .. entry.parsed_name
end

M.pwshCdExec = function()
  local dir = oil.get_current_dir()
  local entry = oil.get_cursor_entry()
  if not dir or not entry then return '' end
  return 'cd ' .. dir .. '; .\\' .. entry.parsed_name
end

return M
