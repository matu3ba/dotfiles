--! Dependecy harpoon
local M = {}
local has_nvimgdb, _ = pcall(require, 'nvimgdb')

if not has_nvimgdb then
  --error 'Please install sakhnik/nvim-gdb
  return
end

--local utils = require("my_utils");

M.trysend = function()
  -- sending command to gdb
  NvimGdb.i():
print


return M
