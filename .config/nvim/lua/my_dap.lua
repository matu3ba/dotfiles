--! Dependency dap, dapui
--! Debugging :lua require('dap').set_log_level('TRACE')

-- luacheck: globals vim
-- luacheck: no max line length
-- Usage nvim-dap-ui: e, expand <CR>/left mouse, o, d, r,t

-- SHENNANIGAN
-- 0. 'stopOnEntry = true' shows assembly instead of source location
-- 1. no dynamic configuration of adapters
-- 2. no dynamic command configuration
-- 3. no attach without lowering whole system security
-- 4. unspecified if debug consolea allows everything debugger can do (ie gdb)
--    or what the supported scope is (and how to workaround because only 1 ptrace
--    is allowed)

-- SHENNANIGAN
-- 1. ptrace allows only one process to debug the target process
-- 2. gdbserver multiview is unfinished,  so only one gdb session can be active

local M = {}
local has_dap, dap = pcall(require, 'dap')
local has_dapui, dapui = pcall(require, 'dapui')
local has_neodev, neodev = pcall(require, 'neodev')
local _ = dap

if not has_dap or not has_dapui then return end

if has_neodev then neodev.setup {
  library = { plugins = { 'nvim-dap-ui' }, types = true },
} end

if not has_dap or not has_dapui then
  vim.print 'no dap or no dapui'
  return
end

--==adapters
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-vscode', -- adjust as needed
  name = 'lldb',
}

-- ==configurations
-- dap has
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file') end,
    cwd = '${workspaceFolder}',
    stopOnEntry = true,
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

-- idea: attach via pgrep instead of this forced static spawning
-- see SHENNANIGAN
-- dap.configurations.cpp = {
--     {
--       name = "Attach to process",
--       type = 'lldb',
--       request = 'attach',
--       pid = require('dap.utils').pick_process,
--       args = {},
--     },
-- }

-- If you want to use this for rust and c, add something like this:
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

-- 1. https://github.com/rcarriga/cmp-dap
-- The following should print true when you are in an active debug session for cmp-dap to work:
-- :lua= require("dap").session().capabilities.supportsCompletionsRequest
-- https://github.com/mfussenegger/nvim-dap/wiki/

dapui.setup()

return M
