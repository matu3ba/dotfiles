--! Dependecy harpoon
--! TODO cmds
local M = {}
local has_harpoon, harpoon = pcall(require, 'harpoon')
local has_harpoonterm, harp_term = pcall(require, 'harpoon.term')

--====harpoon2 usage blocked by
-- 1. What would be a sane setup with potentially necessary default values, ie empty files 1+2?
-- 2. Why is there "removeAt" indicating the list can be segmented, but no addAt or better replaceAt or insertAt?
-- 3. What are the callbacks used or intended for "REMOVE", "ADD" and "SELECT" ?
-- best practice is an explanation on what guarantees the interfaces must support/edge cases to handle
-- in the callback fn as to not break things.
--
-- local has_harpoon, harpoon = pcall(require, 'harpoon')
-- if has_harpoon then
--   -- local fill_files
--    -- vim.keymap.set('n', '<leader>mv', function() harpoon:list():append() end)
--    vim.keymap.set('n', '<leader>mv', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
--    vim.keymap.set('n', '<leader>j', function() harpoon:list():select(1) end)
--    vim.keymap.set('n', '<leader>k', function() harpoon:list():select(2) end)
--    vim.keymap.set('n', '<leader>l', function() harpoon:list():select(3) end)
--    vim.keymap.set('n', '<leader>u', function() harpoon:list():select(4) end)
--    vim.keymap.set('n', '<leader>i', function() harpoon:list():select(5) end)
--    vim.keymap.set('n', '<leader>o', function() harpoon:list():select(6) end)
-- end


if not has_harpoon or not has_harpoonterm then
  --error 'Please install matu3ba/harpoon'
  return
end

local utils = require 'my_utils'

M.bashCmdLogAndExec = function(harpoon_term_nr)
  -- Escape ensures visual mode in vi mode
  harp_term.sendCommand(harpoon_term_nr, '\27')
  -- open cli args in EDITOR (other neovim instance)
  harp_term.sendCommand(harpoon_term_nr, 'v')
  -- send the log lua function exec cmd to other neovim instance
  harp_term.sendCommand(harpoon_term_nr, ":lua local ut=require('my_utils');ut.appDateLog(ut.getCurrLinePlNL())\n")
  -- quit other neovim instance
  harp_term.sendCommand(harpoon_term_nr, ':q\n')
  -- shell will execute command
end

M.lineUnderCursorLogAndSendToShell = function(harpoon_term_nr)
  local currLinePlNL = utils.getCurrLinePlNL()
  utils.appDateLog(currLinePlNL)
  harp_term.sendCommand(harpoon_term_nr, currLinePlNL)
end

M.setCursorToBottom = function(harpoon_term_nr)
  local term_handle = harp_term.getBufferTerminalId(harpoon_term_nr)
  local buf_id = term_handle['buf_id']
  local term_id = term_handle['term_id']
  local windows = vim.fn.win_findbuf(buf_id)
  if #windows ~= 1 then return end
  local crowcount = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_win_set_cursor(windows[1], { crowcount, 0 })
end

return M