--! Dependecy harpoon
local M = {}
local has_harpoon, harpoon = pcall(require, 'harpoon')
local has_harpoonterm, harp_term = pcall(require, 'harpoon.term')

if not has_harpoon or not has_harpoonterm then
  --error 'Please install ThePrimeagen/harpoon
  return
end

local utils = require("my_utils");

M.bashCmdLogAndExec = function(harpoon_term_nr)
  -- Escape ensures visual mode in vi mode
  harp_term.sendCommand(harpoon_term_nr, "\27")
  -- open cli args in EDITOR (other neovim instance)
  harp_term.sendCommand(harpoon_term_nr, "v")
  -- send the log lua function exec cmd to other neovim instance
  harp_term.sendCommand(harpoon_term_nr, ":lua local ut=require('my_utils');ut.appDateLog(ut.getCurrLinePlNL())\n")
  -- quit other neovim instance
  harp_term.sendCommand(harpoon_term_nr, ":q\n")
  -- shell will execute command
end

M.lineUnderCursorLogAndSendToShell = function(harpoon_term_nr)
  local currLinePlNL = utils.getCurrLinePlNL();
  utils.appDateLog(currLinePlNL);
  harp_term.sendCommand(harpoon_term_nr, currLinePlNL)
end

M.setCursorToBottom = function(harpoon_term_nr)
  local term_handle = harp_term.getBufferTerminalId(harpoon_term_nr)
  local buf_id = term_handle["buf_id"]
  local term_id = term_handle["term_id"]
  local windows = vim.fn.win_findbuf(buf_id)
  if #windows ~= 1 then
    return
  end
  local crowcount = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_win_set_cursor(windows[1], { crowcount, 0 })
end

return M
