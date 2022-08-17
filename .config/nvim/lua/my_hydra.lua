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

-- local window_hint = [[
--  ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
--  ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
--  ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally
--  _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
--  ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_, _c_: close
--  focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize
--  ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
--  _b_: choose buffer
-- ]]

-- keep it simple
M.window_hdyra = Hydra({
   body = '<C-w>',
   heads = {
      { 'h', '<C-w>h' },
      { 'j', '<C-w>j' },
      { 'k', '<C-w>k' },
      { 'l', '<C-w>l' },
      { '<Esc>', nil,  { exit = true, desc = false } },
   },
})
-- M.window_hdyra = Hydra({
--    name = 'Window navigation',
--    hint = window_hint,
--    config = {
--        invoke_on_body = true,
--    --    hint = {
--    --       border = 'rounded',
--    --       --offset = -1
--    --    },
--    },
--    mode = 'n',
--    body = '<C-w>',
--    heads = {
--       { 'h', '<C-w>h' },
--       { 'j', '<C-w>j' },
--       -- not sure why hydra wiki uses below command
--       --{ 'k', pcmd('wincmd k', 'E11', 'close') },
--       --{ 'k', '<C-w>k' },
--       { 'l', '<C-w>l' },
--       -- { '=', '<C-w>=', { desc = 'equalize'} },
--       -- { 's',     pcmd('split', 'E36') },
--       -- { '<C-s>', pcmd('split', 'E36'), { desc = false } },
--       -- { 'v',     pcmd('vsplit', 'E36') },
--       -- { '<C-v>', pcmd('vsplit', 'E36'), { desc = false } },
--       -- TODO resizing <,>,+,-
--       -- TODO swapping windows
--       -- { 'c',     pcmd('close', 'E444') },
--       -- { 'q',     pcmd('close', 'E444'), { desc = 'close window' } },
--       -- { '<C-c>', pcmd('close', 'E444'), { desc = false } },
--       -- { '<C-q>', pcmd('close', 'E444'), { desc = false } },
--       { '<Esc>', nil,  { exit = true, desc = false } },
--    },
-- })

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
