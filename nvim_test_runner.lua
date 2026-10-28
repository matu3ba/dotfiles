-- Usage
-- * nvim --headless --clean -l nvim_test_runner.lua
-- * DEBUG=1 nvim --headless --clean -l nvim_test_runner.lua
-- * find . -name "*.lua" | entr -c nvim --headless --clean -l nvim_test_runner.lua

--=imports
--=tests_state
--=functions
--=tests_exec
--=tests_result

-- No convention in neovim how to do debug logs, log redirection etc.
local is_debug = os.getenv 'DEBUG' == '1' or os.getenv 'NVIM_LOG_LEVEL' == 'debug'
local home = vim.env.HOME
assert(home, '❌ FAIL: could not find $HOME')
local want_dir = vim.fs.joinpath(home, 'dotfiles')
local current_dir = vim.uv.cwd()
assert(want_dir == current_dir, string.format("❌ FAIL: current_dir: '%s', wanted_dir: '%s'", current_dir, want_dir))
local lua_dir = vim.fs.joinpath(want_dir, '.config', 'nvim', 'lua')
local path_pattern = vim.fs.joinpath(lua_dir, '?.lua')
package.path = path_pattern .. ';'

package.loaded['my_buf'] = nil
package.loaded['my_utils'] = nil

--=imports
local bu = require 'my_buf'
local ut = require 'my_utils'
-- print('moduls:', vim.inspect(bu)) -- debug

--=tests_state
local failures = 0

--=functions
local function debug_print(string)
  if is_debug then print(string) end
end

local function assert_eq(expected, actual, desc)
  if expected ~= actual then
    print(string.format("❌ FAIL: '%s | Exp: '%q' | Act: '%q'", desc, expected, actual))
    failures = failures + 1
  else
    debug_print(string.format('✅ PASS: %s', desc))
  end
end

local function assert_deep_eq(expected, actual, desc)
  if not vim.deep_equal(expected, actual) then
    print(string.format("❌ FAIL: '%s' | Exp: '%s' | Act: '%s'", desc, vim.inspect(expected), vim.inspect(actual)))
    failures = failures + 1
  else
    debug_print(string.format('✅ PASS: %s', desc))
  end
end

local function run_ut_shift(text, start_b, end_b, dir, mode)
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

local function run_bu_test1()
  debug_print 'run_bu_test1..'
  local tmp_dir = vim.uv.os_tmpdir()
  local tmp_path = tmp_dir .. '/nv_tmp_' .. vim.uv.hrtime() .. '.tmp'
  local tmp_fd, err = io.open(tmp_path, 'w+b')
  assert(tmp_fd, string.format("❌ FAIL: '%s' on creating '%s'", err, tmp_path))
  local content = [[
0123456789abcde0:C:\code
1123456789abcde1:/home/testme/
2123456789abcde2:/]]
  tmp_fd:write(content)
  local expect_shas = { '0123456789abcde0', '1123456789abcde1', '2123456789abcde2' }
  local expect_paths = { [[C:\code]], '/home/testme/', '/' }
  local expect_sha_bytes = { { 0, 15 }, { 25, 40 }, { 56, 71 } }
  local expect_path_bytes = { { 17, 23 }, { 42, 54 }, { 73, 73 } }
  local next, fd, init_offset = bu.records(tmp_fd, 0)
  local line_i = 0
  for _pos, offset_sha, len_sha, offset_path, len_path in next, fd, init_offset do
    line_i = line_i + 1
    tmp_fd:seek('set', offset_sha)
    local raw_sha = tmp_fd:read(len_sha)
    tmp_fd:seek('set', offset_path)
    local raw_path = tmp_fd:read(len_path)
    assert_eq(expect_shas[line_i], raw_sha, 'unexected sha')
    assert_eq(expect_paths[line_i], raw_path, 'unexected path')
    ---@cast expect_sha_bytes any
    ---@cast expect_path_bytes any
    assert_eq(expect_sha_bytes[line_i][1], offset_sha, 'unexected file offset of sha start')
    assert_eq(expect_sha_bytes[line_i][2], offset_sha + len_sha - 1, 'unexected file offset of sha end')
    assert_eq(expect_path_bytes[line_i][1], offset_path, 'unexected file offset of path start')
    assert_eq(expect_path_bytes[line_i][2], offset_path + len_path - 1, 'unexected file offset of path end')

    debug_print(string.format("SHA: '%s' | Path: '%s' (Bytes: [%d-%d] [%d-%d])", raw_sha, raw_path, offset_sha, offset_sha + len_sha - 1, offset_path, offset_path + len_path - 1))
  end
  tmp_fd:close()
  os.remove(tmp_path)

  debug_print 'run_bu_test1 done'
end

local function run_bu_test2()
  debug_print 'run_bu_test2..'
  local tmp_path = vim.uv.os_tmpdir() .. '/nv_tmp_' .. vim.uv.hrtime() .. '.tmp'
  local tmp_fd = assert(io.open(tmp_path, 'w+b'))

  ---@class CaseData
  ---@field sha string
  ---@field data table
  ---@field sha_s? integer
  ---@field sha_e? integer
  ---@field json_s? integer
  ---@field json_e? integer
  ---@field json_str? string

  ---@type CaseData[]
  local cases = {
    { sha = '0123456789abcde0', data = {} },
    { sha = '1123456789abcde1', data = { ['0'] = { { 1, 'init.lua' }, { 2, 'main.c' } }, ['1'] = { { 3, 'term1' } } } },
    { sha = '2123456789abcde2', data = { ['0'] = { { 1, { 'src/core.lua', '/home' } } }, ['1'] = { { 2, { 'term2', '/home' } } } } },
  }

  -- encode json and calculate byte offsets
  local current_offset = 0
  for _, c in ipairs(cases) do
    c.json_str = vim.json.encode(c.data)
    c.sha_s = current_offset
    c.sha_e = c.sha_s + #c.sha - 1
    c.json_s = c.sha_e + 2 -- +1 for ':'
    c.json_e = c.json_s + #c.json_str - 1
    current_offset = c.json_e + 2 -- +1 for '\n'
  end

  local lines = {}
  for _, c in ipairs(cases) do
    table.insert(lines, string.format('%s:%s', c.sha, c.json_str))
  end
  tmp_fd:write(table.concat(lines, '\n'))
  tmp_fd:flush()

  local next, fd, init_offset = bu.records(tmp_fd, 0)
  local line_i = 0

  for _pos, o_sha, l_sha, o_json, l_json in next, fd, init_offset do
    line_i = line_i + 1
    local c = assert(cases[line_i], 'Iteriert über erwartete Testfälle hinaus')

    tmp_fd:seek('set', o_sha)
    assert_eq(c.sha, tmp_fd:read(l_sha), 'unexpected sha')

    tmp_fd:seek('set', o_json)
    local raw_json = tmp_fd:read(l_json)
    assert_eq(c.json_str, raw_json, 'unexpected json string')

    assert_eq(c.sha_s, o_sha, 'sha start offset mismatch')
    assert_eq(c.sha_e, o_sha + l_sha - 1, 'sha end offset mismatch')
    assert_eq(c.json_s, o_json, 'json start offset mismatch')
    assert_eq(c.json_e, o_json + l_json - 1, 'json end offset mismatch')

    -- compare json structure
    assert_deep_eq(c.data, vim.json.decode(raw_json), string.format "json data structure mismatch: ''")

    debug_print(string.format("SHA: '%s' | JSON: '%s' (Bytes: [%d-%d] [%d-%d])", c.sha, raw_json, o_sha, o_sha + l_sha - 1, o_json, o_json + l_json - 1))
  end

  assert_eq(#cases, line_i, 'Nicht alle Testfälle wurden iteriert')
  tmp_fd:close()
  os.remove(tmp_path)
  debug_print 'run_bu_test2 done'
end

local function run_bu_tests()
  debug_print 'run_bu_tests..'
  run_bu_test1()
  run_bu_test2()
  debug_print 'run_bu_tests done'
end

local function run_ut_tests()
  debug_print 'run_ut_tests..'

  -- ASCII Tests (shifting inside strings)
  assert_eq('adbce', run_ut_shift('abcde', 2, 4, 'right', 'wraparound'), 'ASCII R Wrap')
  assert_eq('acdbe', run_ut_shift('abcde', 2, 4, 'left', 'wraparound'), 'ASCII L Wrap')
  assert_eq('a bce', run_ut_shift('abcde', 2, 4, 'right', 'saturation'), 'ASCII R Sat')
  assert_eq('acd e', run_ut_shift('abcde', 2, 4, 'left', 'saturation'), 'ASCII L Sat')

  -- UTF-8 Multibyte Tests (🚀 = 4 Bytes [1-4], 🔥 = 4 Bytes [5-8])
  assert_eq('🔥🚀', run_ut_shift('🚀🔥', 1, 8, 'right', 'wraparound'), 'UTF8 R Wrap')
  assert_eq(' 🚀', run_ut_shift('🚀🔥', 1, 8, 'right', 'saturation'), 'UTF8 R Sat')

  debug_print 'run_ut_tests done'
end

--=tests_exec
run_bu_tests()
run_ut_tests()

--=tests_result
if failures > 0 then
  vim.cmd 'cquit'
else
  debug_print 'Result: OK.'
  os.exit(0)
end
