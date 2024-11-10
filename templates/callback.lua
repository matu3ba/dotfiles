-- luacheck: globals vim
-- small callback fn by xorg-dogma
-- Generally speaking, callback can be identified by () after the function argument.
-- This allows to be called function to be given as arguments.
-- The order is only relevant, if a variable number of arguments is used.

-- Execute with: nvim -l templates/callback.lua
local function prepend_icon(callback, icon, spacing, ...) return icon .. spacing .. callback(...) end

local result = prepend_icon(function(...)
  local message_fragments = { ... }
  local message = table.concat(message_fragments, ' ')
  return message
end, ' ', ' ', 'My', 'name', 'is', 'Jon', 'Doe.')

vim.print(result)
