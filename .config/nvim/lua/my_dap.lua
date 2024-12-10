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

if not has_dap then
  vim.print 'no dap installed'
  return
end

if not has_dapui then
  vim.print 'no dapui installed'
  return
end

--==adapters
dap.adapters.lldb = {
  type = 'executable',
  command = '/usr/bin/lldb-dap', -- lldb-vscode was renamed to lldb-dap
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

vim.keymap.set('n', ',b', dap.toggle_breakpoint)
vim.keymap.set('n', ',gb', dap.run_to_cursor)
vim.keymap.set('n', ',o', dap.repl.open)
vim.keymap.set('n', ',q', dap.terminate)

-- vim.keymap.set('n', ',gc', dap.goto_())
-- vim.keymap.set('n', ',e', function() dapui.eval(nil, { enter = true }) end)

-- TODO dap.pause
-- dap.up, dap.down
-- dap.reverse_continue
-- dap.focus_frame
-- dap.restart_frame

-- vim.keymap.set('n', ',1', dap.continue)
-- vim.keymap.set('n', ',2', dap.step_into)
-- vim.keymap.set('n', ',3', dap.step_over)
-- vim.keymap.set('n', ',4', dap.step_out)
-- vim.keymap.set('n', ',5', dap.step_back)
-- vim.keymap.set('n', ',12', dap.restart)
vim.keymap.set('n', '<F1>', dap.continue)
vim.keymap.set('n', '<F2>', dap.step_into)
vim.keymap.set('n', '<F3>', dap.step_over)
vim.keymap.set('n', '<F4>', dap.step_out)
vim.keymap.set('n', '<F5>', dap.step_back)
vim.keymap.set('n', '<F12>', dap.restart)
-- TODO: how to get debug position for setting cursor there?
-- TODO: reverse step setup with rr + gdb
-- TODO: wingbd setup, microsoft reverse stepping?
-- TODO: list and clear debug points
-- TODO: SIGINT process under debug and get backtrace etc

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

-- 1. https://github.com/rcarriga/cmp-dap
-- The following should print true when you are in an active debug session for cmp-dap to work:
-- :lua= require("dap").session().capabilities.supportsCompletionsRequest
-- https://github.com/mfussenegger/nvim-dap/wiki/
-- dap.setup()
dapui.setup()

return M
