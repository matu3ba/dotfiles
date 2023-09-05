--! Dependency dap, dapui
-- luacheck: globals vim
-- luacheck: no max line length

local M = {}
local has_dap, dap = pcall(require, 'dap')
local has_dapui, dapui = pcall(require, 'dapui')
local has_neodev, neodev = pcall(require, 'neodev')
local _ = dap

if not has_dap or not has_dapui then
  return
end

if has_neodev then
  neodev.setup {
    library = { plugins = { "nvim-dap-ui" }, types = true },
  }
end

if not has_dap or not has_dapui then
  vim.print("no dap or no dapui")
  return
end

--==general_config
-- dap.adapters.lldb = {
--   type = 'executable',
--   command = '/usr/bin/lldb-vscode', -- adjust as needed
--   name = 'lldb',
-- }

-- TODO: attach via pgrep instead of this forced static spawning

dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
    -- Otherwise you might get the following error:
    --    Error on launch: Failed to attach to the target process
    -- But you should be aware of the implications:
    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
    runInTerminal = false,
  },
}

-- If you want to use this for rust and c, add something like this:
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- TODO
--The selected configuration references adapter `lldb`, but dap.adapters.lldb is undefined


-- 1. https://github.com/rcarriga/cmp-dap
-- The following should print true when you are in an active debug session for cmp-dap to work:
-- :lua= require("dap").session().capabilities.supportsCompletionsRequest
-- https://github.com/mfussenegger/nvim-dap/wiki/

dapui.setup()

return M
