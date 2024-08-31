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
if not has_overseer then
  vim.print("no overseer")
  return
end
local constants = require("overseer.constants")
local STATUS = constants.STATUS

-- if not has_overseer_util then
--   vim.print("no overseer.util")
--   return
-- end
-- local bufnr = task:get_bufnr()
-- if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
--   -- naming tabs requires involved statusline-like setup
--   -- https://www.reddit.com/r/neovim/comments/pcpxwq/permanent_name_for_tab/
--   vim.cmd.tabnew()
--   overseer_util.set_term_window_opts()
--   vim.api.nvim_win_set_buf(0, task:get_bufnr())
--   overseer_util.scroll_to_end(0)
-- end

overseer.setup({
  actions = {
    ["validate"] = {
      desc = "Create and execute derived task to validate result",
      condition = function(task)
        return not task:has_component("validate") -- dont validate validation
          and (task.status == STATUS.SUCCESS or task.status == STATUS.FAILURE)
      end,
      run = function(task)
        -- print(task:has_component("validate")) -- DEBUG
        local newtask = overseer.new_task({
            cmd = task.cmd;
            cwd = task.cwd;
            env = task.env;
            name = "val_" .. task.name;
            components = {
                "validate",
                "on_complete_notify",
                "default"
            }
        })
        newtask:start()
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

local function get_task_callback(task_i, action)
  return function()
    -- local tasks = require("overseer").list_tasks({ recent_first = true })
    local tasks = require("overseer").list_tasks()
    local task = tasks[task_i]
    if task then
      require("overseer").run_action(task, action)
    end
  end
end

-- local function get_task_callback_byid(task_id, action)
--   return function()
--     local tasks = require("overseer").list_tasks()
--     for i = 1, #tasks do
--       local task = tasks[i]
--       if task and task.id == task_id then
--         if action == "print_info" then
--           print(task.id, task.name, task.status)
--         else
--           require("overseer").run_action(task, action)
--         end
--       end
--     end
--   end
-- end

-- ;1..9 ;e1..9 ;o1..9 ;p1..9 ;t1..9
for i = 1, 9 do
  vim.keymap.set("n", ";o" .. i, get_task_callback(i, 'open'), { desc = string.format("Open output here task #%d", i) })
  vim.keymap.set("n", ";t" .. i, get_task_callback(i, 'open tab'), { desc = string.format("Open output tab task #%d", i) })
  vim.keymap.set("n", ";e" .. i, get_task_callback(i, 'edit'), { desc = string.format("Edit task #%d", i) })
  vim.keymap.set("n", ";" .. i, get_task_callback(i, 'restart'), { desc = string.format("Restart task #%d", i) })
  vim.keymap.set("n", ";p" .. i, get_task_callback(i, 'print_info'), { desc = string.format("Print id of task #%d", i) })
end

vim.keymap.set("n", ";bs", function()
  local bundle_name = vim.fs.basename(vim.fn.getcwd())
  require("overseer").save_task_bundle(bundle_name, nil, { on_conflict = "overwrite" })
end)
vim.keymap.set("n", ";bl", function()
  local bundle_name = vim.fs.basename(vim.fn.getcwd())
  require("overseer").load_task_bundle(bundle_name)
end)

-- local function validate_callback(task_id, exact)
--   return function()
--     local tasks = require("overseer").list_tasks()
--     for i = 1, #tasks do
--       local task = tasks[i]
--       if task and task.id == task_id then
--         local tst = task.status
--         if tst == "PENDING" or tst == "RUNNING" or tst == "CANCELED" or tst == "DISPOSED" then
--           print("can not validate, operation " .. tst)
--         else
--           require("overseer").run_action(task, 'restart')
--           -- TODO wait for finishing in background to compare
--           -- => schedule comparison, which schedules itself back
--         end
--       end
--     end
--   end
-- end

-- :echo stdpath('config')
-- ~/.config/nvim/lua/overseer/template/user/cpp_build.lua
-- ~/.config/nvim/lua/overseer/template/user/run_script.lua

-- Unclaer if bug or old version
-- im/lazy/overseer.nvim/lua/overseer/strategy/jobstart.lua:100: in function 'on_stdout'
-- im/lazy/overseer.nvim/lua/overseer/strategy/jobstart.lua:139: in function <...im/lazy/overseer.nvim/lua/overseer/strategy/jobstart.lua:135> function:
-- builtin#18 ...im/lazy/overseeer.nvim/lua/overseer/strategy/jobstart.lua:110: 'replacement string' item contains newlines

-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/pwjworks/neovim-config/blob/9f3887c7eb7965f50a76ed6ff8a8844aa095967b/lua/plugins/lsp.lua#L55
-- https://github.com/mawkler/nvim/blob/3012b841718b5ac2bc38e741c0b34c364d5eb9db/lua/configs/overseer.lua#L5
-- https://github.com/Lap1n/dotfiles/blob/c1badbceb2078af245ae8596cafb3f6c6053a63f/nvim/lua/plugins/overseer.lua#L4
--
-- author of overseer
-- https://github.com/stevearc/dotfiles
-- https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/overseer.lua
