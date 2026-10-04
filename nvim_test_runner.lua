-- Usage
-- * nvim --headless --clean -l nvim_test_runner.lua
-- * DEBUG=1 nvim --headless --clean -l nvim_test_runner.lua

-- No convention in neovim how to do debug logs, log redirection etc.
local is_debug = os.getenv 'DEBUG' == '1' or os.getenv 'NVIM_LOG_LEVEL' == 'debug'

local current_dir = vim.fn.getcwd()
package.path = package.path .. ';' .. current_dir .. '/.config/nvim/lua/my_utils.lua'
local ut = require 'my_utils'

local failures = 0
local function debug_print(string)
  if is_debug then print(string) end
end

local function assert_eq(expected, actual, desc)
  if expected ~= actual then
    print(string.format('❌ FAIL: %s | Exp: %q | Act: %q', desc, expected, actual))
    failures = failures + 1
  else
    debug_print(string.format('✅ PASS: %s', desc))
  end
end

local function run(text, start_b, end_b, dir, mode)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  local win = vim.api.nvim_open_win(buf, true, { relative = 'editor', row = 0, col = 0, width = 40, height = 5, style = 'minimal' })

  vim.api.nvim_win_call(win, function()
    -- Setze die exakten Byte-Positionen
    vim.api.nvim_win_set_cursor(win, { 1, start_b - 1 })
    vim.cmd 'normal! v'
    vim.api.nvim_win_set_cursor(win, { 1, end_b - 1 })

    ut.textSelectionShift(dir, mode)
  end)

  local res = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] or ''
  vim.api.nvim_win_close(win, true)
  vim.api.nvim_buf_delete(buf, { force = true })
  return res
end

debug_print 'Start minimized config tests..'

-- ASCII Tests (Verschiebung innerhalb des Strings)
assert_eq('adbce', run('abcde', 2, 4, 'right', 'wraparound'), 'ASCII R Wrap')
assert_eq('acdbe', run('abcde', 2, 4, 'left', 'wraparound'), 'ASCII L Wrap')
assert_eq('a bce', run('abcde', 2, 4, 'right', 'saturation'), 'ASCII R Sat')
assert_eq('acd e', run('abcde', 2, 4, 'left', 'saturation'), 'ASCII L Sat')

-- UTF-8 Multibyte Tests (🚀 = 4 Bytes [1-4], 🔥 = 4 Bytes [5-8])
assert_eq('🔥🚀', run('🚀🔥', 1, 8, 'right', 'wraparound'), 'UTF8 R Wrap')
assert_eq(' 🚀', run('🚀🔥', 1, 8, 'right', 'saturation'), 'UTF8 R Sat')

debug_print '-------------------------------------------'
if failures > 0 then
  vim.cmd 'cquit'
else
  debug_print 'Result: OK.'
  os.exit(0)
end
