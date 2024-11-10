-- Overall, I'm happy with my setup, but I must admit that I feel more productive
-- debugging inside Visual Studio (typically C++).

local M = {}

-- SHENNANIGAN :q! or ZQ on window drops data.
-- SHENNANIGAN no harpoon-like speed to run things for example with overseer
-- SHENNANIGAN: getpos has 1-indexed columns vs nvim_win_set_cursor 0-indexed
-- SHENNANIGAN no vim/neovim docs on how multple newlines should be serialized and
-- deserialized to be visualized on 1 line.
-- SHENNANIGAN Window system installation tries to use system location for language files,
-- for which download fails due to missing write permissions.

-- SHENNANIGAN copying in hex 22ef bfbd 22 (from latin encoding of degree via
-- <degree>) breaks due to control character execution at least

-- https://github.com/neovim/neovim/pull/30261/files

-- SHENNANIGAN: '<', '>' still advertised as cursor positions, but its only extmarks
-- cursor positions are 'v' for first and '.' for last selection positions
-- bufnum, lnum, col, off

-- SHENNANIGAN Lua code to get selection unnecessary complex due to
-- callback requirement during invoking or does not handle all edge cases.
-- As example, one needs to use nvim_buf_get_mark within commands and
-- vim.fn.getpos within keymaps due to commmand mode in neovim leaving
-- the visual mode without storing how the selection has been generated.
M.printSelectionAndMode = function()
  -- SHENNANIGAN There is no sane way to get the mode of how the extmark or
  -- position was generated with vim.api.nvim_buf_get_mark(0, "<,>") or
  -- vim.fn.getpos 'v,.'
  -- local vstart = vim.fn.getpos 'v'
  -- local vend = vim.fn.getpos '.'
  -- vim.print(vstart, vend)
  local start_pos = vim.api.nvim_buf_get_mark(0, '<') -- 1,0 indexed line,col
  local end_pos = vim.api.nvim_buf_get_mark(0, '>')
  vim.print(
    ":'<,'> (" .. tostring(start_pos[1]) .. ':' .. tostring(start_pos[2]) .. '),' .. '(' .. tostring(end_pos[1]) .. ':' .. tostring(end_pos[2]) .. ') ',
    vim.api.nvim_get_mode().mode
  )
end
vim.api.nvim_create_user_command('VPrintSelMode', M.printSelectionAndMode, { range = true })

return M
