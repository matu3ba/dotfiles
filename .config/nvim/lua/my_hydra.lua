local ok_hydra, Hydra = pcall(require, "hydra")
if not ok_hydra then
  vim.notify("hydra not installed...", vim.log.ERROR)
  return
end

--local cmd = require('hydra.keymap-util').cmd
--local pcmd = require('hydra.keymap-util').pcmd

-- note hydra keybinding to attach + send cmds to debug session
-- should this session be in harpoon? in hydra?

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

M.window_hdyra = Hydra({
   body = '<C-w>',
   heads = {
      -- The following depend highly on your workflow
      -- { 'h', '<C-w>h' },
      -- { 'j', '<C-w>j' },
      -- { 'k', '<C-w>k' },
      -- { 'l', '<C-w>l' },
      -- other use cases: scrolling (C-d,C-u,C-e,C-y), copy+paste
      { 's', '<C-w>s' },
      { 'v', '<C-w>v' },
      { '+', '<C-w>+' },
      { '-', '<C-w>-' },
      { '>', '<C-w>>' },
      { '<', '<C-w><' },
      { '=', '<C-w>=' },
      { 'q', '<cmd>close<CR>' },
      { 'o', '<cmd>only<CR>' },
      { '_', '<C-w>_' },
      { '|', '<C-w>|' },
      { '<Esc>', nil,  { exit = true, desc = false } },
   },
})

-- keep buffers simple and fast
M.window_hdyra = Hydra({
   body = '<leader>b',
   heads = {
      -- note https://github.com/anuvyklack/hydra.nvim/issues/39
      { 's', '<cmd>ls<CR>' }, -- show buffers
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
 ^ ^ _J_ ^ ^                      _<C-c>_
]]

-- :setlocal ve=all
-- :setlocal ve=none
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
         vim.wo.virtualedit = 'all'
      end,
   },
   mode = 'n',
   body = '<leader>ve',
   heads = {
      { 'H', '<C-v>h:VBox<CR>' },
      { 'J', '<C-v>j:VBox<CR>' },
      { 'K', '<C-v>k:VBox<CR>' },
      { 'L', '<C-v>l:VBox<CR>' },
      { 'f', ':VBox<CR>', { mode = 'v' }},
      { '<C-c>', nil, { exit = true } },
   }
})

local selmove_hint = [[
 Arrow^^^^^^
 ^ ^ _k_ ^ ^
 _h_ ^ ^ _l_
 ^ ^ _j_ ^ ^                      _<C-c>_
]]

local ok_minimove, minimove = pcall(require, "mini.move")
assert(ok_minimove)
if ok_minimove == true then
  local opts = {
    mappings = {
      left  = '', right = '', down  = '', up    = '',
      line_left  = '', line_right = '', line_down  = '', line_up    = '',
    },
  }
  minimove.setup(opts)
  -- setup here prevents needless global vars for opts required by `move_selection()/moveline()`
  M.minimove_box_hydra = Hydra({
     name = 'Move Box Selection',
     hint = selmove_hint,
     config = {
        color = 'pink',
        invoke_on_body = true,
        hint = {
           border = 'rounded'
        },
     },
     mode = 'v',
     body = '<leader>vb',
     heads = {
        { 'h', function() minimove.move_selection("left", opts) end },
        { 'j', function() minimove.move_selection("down", opts) end },
        { 'k', function() minimove.move_selection("up", opts) end },
        { 'l', function() minimove.move_selection("right", opts) end },
        { '<C-c>', nil, { exit = true } },
     }
  })
  M.minimove_line_hydra = Hydra({
     name = 'Move Line Selection',
     hint = selmove_hint,
     config = {
        color = 'pink',
        invoke_on_body = true,
        hint = {
           border = 'rounded'
        },
     },
     mode = 'n',
     body = '<leader>vl',
     heads = {
        { 'h', function() minimove.move_line("left", opts) end },
        { 'j', function() minimove.move_line("down", opts) end },
        { 'k', function() minimove.move_line("up", opts) end },
        { 'l', function() minimove.move_line("right", opts) end },
        { '<C-c>', nil, { exit = true } },
     }
  })
end

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
