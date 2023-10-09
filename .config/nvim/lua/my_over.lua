--! Overseer setup and configuration
--====Commands
-- :OverseerOpen|OverseerClose|OverseerToggle
-- :OverseerSaveBundle, :OverseerLoadBundle, :OverseerDeleteBundle
-- Run a raw shell command: :OverseerRunCmd
-- Run a task from a template: :OverseerRun
-- :OverseerBuild
-- :OverseerQuickAction, :OverseerTaskAction
-- :OverseerClearCache
--==task_list
-- default separator is ─ (U+2500)
-- default keymaps: help: ?|g?, runaction <CR>, C-e edit, o open,
--   windowing: C-s|v|f|q,p, detail: C-h|l|H|L, width+-: [], task: {}, scroll: C-j|k
--==task_launcher
-- i-mode: submit,cancel: C-s,C-c
-- n-mode: submit: C-s|<CR>, cancel: q, help: ?
--==task_editor
-- i-mode: nextorsubmit,submit: <CR>,C-s, prev,next: <Tab>,<S-Tab>, cancel: C-c
-- n-mode: same with help: ?

--====Design
-- no history tracking view

-- luacheck: globals vim
-- luacheck: no max line length

-- Show config with :=require("overseer.config")

local has_overseer, overseer = pcall(require, "overseer")
local has_overseer_util, overseer_util = pcall(require, "overseer.util")

if not has_overseer then
  vim.print("no overseer")
  return
end
if not has_overseer_util then
  vim.print("no overseer.util")
  return
end

overseer.setup({
  actions = {
    ["open tab"] = {
      desc = "Open this task in a new tab",
      run = function(task)
        local bufnr = task:get_bufnr()
        if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
          -- naming tabs requires involved statusline-like setup
          -- https://www.reddit.com/r/neovim/comments/pcpxwq/permanent_name_for_tab/
          vim.cmd.tabnew()
          overseer_util.set_term_window_opts()
          vim.api.nvim_win_set_buf(0, task:get_bufnr())
          overseer_util.scroll_to_end(0)
        end
      end,
    },
  },
  component_aliases = {
    default = {
    { "display_duration", detail_level = 2 },
    "on_output_summarize",
    "on_exit_set_status",
    --"on_complete_notify",
    --"on_complete_dispose", -- this should keep the task
    },
    -- Tasks from tasks.json use these components
    default_vscode = {
      "default",
      "on_result_diagnostics",
      "on_result_diagnostics_quickfix",
    },
  },
  strategy = { "jobstart", use_terminal = false },
  templates = { "builtin", "user.cpp_build", "user.run_script" },
})

-- :echo stdpath('config')
-- ~/.config/nvim/lua/overseer/template/user/cpp_build.lua
-- ~/.config/nvim/lua/overseer/template/user/run_script.lua

-- SHENNANIGAN
-- Closing a tab or buffer of a finished task might drop the data.

-- SHENNANIGAN
-- no harpoon-like speed to run things

-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/pwjworks/neovim-config/blob/9f3887c7eb7965f50a76ed6ff8a8844aa095967b/lua/plugins/lsp.lua#L55
-- https://github.com/mawkler/nvim/blob/3012b841718b5ac2bc38e741c0b34c364d5eb9db/lua/configs/overseer.lua#L5
-- https://github.com/Lap1n/dotfiles/blob/c1badbceb2078af245ae8596cafb3f6c6053a63f/nvim/lua/plugins/overseer.lua#L4
--
-- author of overseer
-- https://github.com/stevearc/dotfiles
-- https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/overseer.lua
