--! lib_buf setup and configuartion.
--! Note, that :so does not work for deletions.
local M = {}
local has_libbuf, libbuf = pcall(require, 'libbuf')
if not has_libbuf then return end

local actions = require 'libbuf.actions'
local dev = require 'libbuf.dev'
local state = require 'libbuf.state'

-- Neovim does not store who the owner of a buffer is.
-- Doing so would allow to unload the buffer and remove or reload
-- plugins identified as too memory greedy or leaking.
local user_setup_fn = function()
  local mbuf_props = actions.currentBuffersWithPropertis()
  libbuf.annotateGroup_cliargs_init(mbuf_props)
  -- Create unshown(in masterbuffer), but listed, scratch buffer.
  local mbuf_h = actions.createHandle(nil)
  state.mbuf_h = mbuf_h
  state._mbuf = mbuf_props
  libbuf.default_populateMasterBuf(mbuf_h, libbuf.default_readwrite_fn, function() end)

  -- Create ripgrep buffer and add annotation to fill search history and results.
  local rghist_h = actions.createHandle(nil)
  local rghist_prop = actions.currentBufferWithProperty(rghist_h)
  rghist_prop['group'] = 'rghist'
  rghist_prop['limit_size'] = false
  state._mbuf[#state._mbuf + 1] = rghist_prop
  local rgsearch_h = actions.createHandle(nil)
  local rgsearch_prop = actions.currentBufferWithProperty(rgsearch_h)
  rgsearch_prop['group'] = 'rgsearch'
  rgsearch_prop['limit_size'] = 1000000 -- 10^6 = ca. 10MB
  state._mbuf[#state._mbuf + 1] = rgsearch_prop
end

-- General startup procedure idea:
-- 1. Neovim setup finished (libbuf.delayedSetup)
-- 2. user_setup_fn is called
-- 2.1 try to recover current buffer properties of listed files (cli opened files, default ones)
-- 2.2 create master handle (listed, read+write)
-- 2.3 provide state.lua with the info
-- 2.4 TODO load filesystem index info + combine it with state buffer info
-- 2.5 TODO set function to redraw master buffer
-- 2.6 TODO register autcommands with actions to do if master buffer is changed
-- 2.7 fixed user handles for output functionality
-- 2.8 annotated buffer size limits for runner api
-- 2.9 TODO (if possible) emergency buffer write commands to prevent data loss
libbuf.delayedSetup(user_setup_fn)

local api = vim.api
local add_cmd = api.nvim_create_user_command

---Run cmd with command line arguments
---@param cmdline string
---@return integer Status Ok (0), NoApplicableCmd (-1), Other (>0)
M.runCmd = function(cmdline)
  local cmdinfo = actions.splitCmdLine(cmdline)
  local cmd_exe = cmdinfo[1]
  local cmdargs = cmdinfo[2]
  dev.log.trace('cmd_exe: ' .. cmd_exe)
  dev.log.trace('cmdargs: ' .. vim.inspect(cmdargs))
  if cmd_exe == 'rg' then
    local bufprops = state.searchBufOnlyAnnotation('group', 'rghist')
    local rghist_h = bufprops['buf_h']
    assert(rghist_h ~= nil)
    bufprops = state.searchBufOnlyAnnotation('group', 'rgsearch')
    local rgsearch_h = bufprops['buf_h']
    assert(rgsearch_h ~= nil)
    api.nvim_buf_set_lines(rgsearch_h, 0, -1, false, {}) -- empty buffer
    api.nvim_buf_set_lines(rghist_h, -1, -1, true, { cmdline }) -- append to last line
    local _ = actions.runCmdWriteIntoBuffer(rgsearch_h, cmd_exe, cmdargs)
  end

  return -1
end

-- Usually wanted are
-- 1. keymaps to set current window to annotated buffer(s)
-- 2. methods/keymaps to add and remove directories for filesystem index
-- 3. runner control to write into buffer(s)
add_cmd('ShMBuf', function() libbuf.showMasterBuf() end, {})
add_cmd('AddDir', function() libbuf.addDir '.' end, {})
add_cmd('LibbufDumpState', function() state.dumpState '/tmp/state.txt' end, {})
local has_plenary, plenary = pcall(require, 'plenary')
if has_plenary == false then return end
add_cmd('AddFile', function() libbuf.addFile(plenary.path:new(api.nvim_buf_get_name(0)):make_relative()) end, {})
add_cmd('AddDirAndFile', function() libbuf.addDirAndFile(plenary.path:new(api.nvim_buf_get_name(0)):make_relative()) end, {})
add_cmd('RunCmd', function() M.runCmd 'rg test .' end, {})
return M
