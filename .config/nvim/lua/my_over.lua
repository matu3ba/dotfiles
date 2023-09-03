--! Overseer setup and configuration
--==Commands
-- :OverseerOpen|Close|Toggle,
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

local has_overseer, overseer = pcall(require, "overseer")
if not has_overseer then
  vim.print("no overseer")
  return
end

overseer.setup({
  templates = { "builtin", "user.cpp_build", "user.run_script" },
})

-- :echo stdpath('config')
-- ~/.config/nvim/lua/overseer/template/user/cpp_build.lua
-- ~/.config/nvim/lua/overseer/template/user/run_script.lua

-- TODO
-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/abdulmelikbekmez/nvim-config/blob/master/lua/plugins/overseer.lua
-- https://github.com/pwjworks/neovim-config/blob/9f3887c7eb7965f50a76ed6ff8a8844aa095967b/lua/plugins/lsp.lua#L55
-- https://github.com/mawkler/nvim/blob/3012b841718b5ac2bc38e741c0b34c364d5eb9db/lua/configs/overseer.lua#L5
-- https://github.com/Lap1n/dotfiles/blob/c1badbceb2078af245ae8596cafb3f6c6053a63f/nvim/lua/plugins/overseer.lua#L4
--
-- author of overseer
-- https://github.com/stevearc/dotfiles
-- https://github.com/stevearc/dotfiles/blob/master/.config/nvim/lua/plugins/overseer.lua
