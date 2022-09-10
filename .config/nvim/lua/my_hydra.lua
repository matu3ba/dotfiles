local ok_hydra, Hydra = pcall(require, "hydra")
if not ok_hydra then
  vim.notify("hydra not installed...", vim.log.ERROR)
  return
end

--local cmd = require('hydra.keymap-util').cmd
--local pcmd = require('hydra.keymap-util').pcmd

local M = {}

-- local ok_dap, dap = pcall(require, "hydra")
-- if ok_dap then
--   dap is installed
--   local is_configured
-- end
-- dap hydra for dap operations
-- local dap = require("dap")
-- local dapui = require("dapui")

-- hydra without color
M.sidescroll_hdyra = Hydra({
   name = 'Side scroll',
   mode = 'n',
   body = 'z',
   heads = {
      { 'h', '5zh' },
      { 'l', '5zl', { desc = '←/→' } },
      { 'H', 'zH' },
      { 'L', 'zL', { desc = 'half screen ←/→' } },
   },
})

-- keep window resizing simple and fast
-- leaving hydra mode takes mostly more time, so navigation is not worth it
M.window_hdyra = Hydra({
   body = '<C-w>',
   heads = {
      -- { 'h', '<C-w>h' },
      -- { 'j', '<C-w>j' },
      -- { 'k', '<C-w>k' },
      -- { 'l', '<C-w>l' },
      -- C-d,C-u,C-e,C-y
      -- TODO think of use case to copy paste + insert stuff
      { 's', '<C-w>s' },
      { 'v', '<C-w>v' },
      { '+', '<C-w>+' },
      { '-', '<C-w>-' },
      { '>', '<C-w>>' }, -- idea: use arrow keys to prevent indendation
      { '<', '<C-w><' },
      { '=', '<C-w>=' },
      { 'q', '<cmd>close<CR>' },
      { 'o', '<cmd>only<CR>' },
      --{ '<S>', '<C-w><S>' },
      --{ '_', '<C-w>_' },
      --{ '|', '<C-w>|' }, -- requires prefixed numbers => other hydra heaad
      { '<Esc>', nil,  { exit = true, desc = false } },
   },
})

-- keep buffers simple and fast
M.window_hdyra = Hydra({
   body = '<leader>b',
   heads = {
      -- TODO https://github.com/anuvyklack/hydra.nvim/issues/39
      --{ 's', '<cmd>ls<CR>' }, -- show buffers
      { 'l', '<cmd>bn<CR>' }, -- next buffer
      { 'h', '<cmd>bp<CR>' }, -- previous buffer
      { 'a', '<cmd>ba<CR>' }, -- add current buffer
      { 'q', '<cmd>bd<CR>' }, -- delete current buffer
      { '<Esc>', nil,  { exit = true, desc = false } },
   },
})

local venn_hint = [[
 Arrow^^^^^^   Select region with <C-v>
 ^ ^ _K_ ^ ^   _f_: surround it with box
 _H_ ^ ^ _L_
 ^ ^ _J_ ^ ^                      _<Esc>_
]]

M.venn_hydra = Hydra({
   name = 'Draw Diagram',
   hint = venn_hint,
   config = {
      color = 'pink',
      invoke_on_body = true,
      hint = {
         border = 'rounded'
      },
      on_enter = function()
         vim.o.virtualedit = 'all'
      end,
   },
   mode = 'n',
   body = '<leader>v',
   heads = {
      { 'H', '<C-v>h:VBox<CR>' },
      { 'J', '<C-v>j:VBox<CR>' },
      { 'K', '<C-v>k:VBox<CR>' },
      { 'L', '<C-v>l:VBox<CR>' },
      { 'f', ':VBox<CR>', { mode = 'v' }},
      { '<Esc>', nil, { exit = true } },
   }
})


-- M.dap_hydra = Hydra({
--   name = "dap",
--   mode = "n",
--   -- body = "<leader>d",
--   heads = {
--     -- {
--     -- "c",
--     -- function()
--     -- dap.continue()
--     -- end,
--     -- { desc = "continue" },
--     -- },
--     {
--       "o",
--       function()
--         dap.step_over()
--       end,
--       { desc = "Step over" },
--     },
--     {
--       "O",
--       function()
--         dap.step_out()
--       end,
--       { desc = "Step out" },
--     },
--     {
--       "n",
--       function()
--         dap.step_into()
--       end,
--       { desc = "Step into" },
--     },
--     {
--       "f",
--       function()
--         dapui.float_element("scopes", { enter = true, width = 75 })
--       end,
--       { desc = "toggle scopes in floating window" },
--     },
--   },
--   config = {
--     exit = false,
--     -- run all other keys pressed if they are not a hydra head
--     foreign_keys = "run",
--   },
-- })

-- local hint_relnu = [[
--   ^ ^        Options
--   ^
--   _r_ %{rnu} relative number
--   ^
--        ^^^^                _<Esc>_
-- ]]
-- local options_hydra = Hydra({
--   name = "Options",
--   hint = hint_relnu,
--   config = {
--     color = "amaranth",
--     invoke_on_body = true,
--     hint = {
--       border = "rounded",
--       position = "middle",
--     },
--   },
--   mode = { "n", "x" },
--   -- body = "<leader>o",
--   heads = {
--     {
--       "r",
--       function()
--         if vim.o.relativenumber == true then
--           vim.o.relativenumber = false
--         else
--           vim.o.number = true
--           vim.o.relativenumber = true
--         end
--       end,
--       { desc = "relativenumber" },
--     },
--   },
-- })
--
-- -- options hydra to easily toggle common options
-- vim.api.nvim_create_user_command("Options", function()
-- 	options_hydra:activate()
-- end, {})

return M
