--! Dependecy harpoon
local M = {}
local has_harpoon, harpoon = pcall(require, 'harpoon')
local has_harpoon, harp_term = pcall(require, 'harpoon.term')

if not has_harpoon then
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

return M
