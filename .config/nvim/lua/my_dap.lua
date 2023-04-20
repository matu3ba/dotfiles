--! Dependency dap
local M = {}
local has_dap, dap = pcall(require, 'dap')

if not has_dap then return end
-- 1. https://github.com/rcarriga/cmp-dap
-- The following should print true when you are in an active debug session for cmp-dap to work:
-- :lua= require("dap").session().capabilities.supportsCompletionsRequest
-- https://github.com/mfussenegger/nvim-dap/wiki/

local _ = dap
-- TODO finish up

return M
