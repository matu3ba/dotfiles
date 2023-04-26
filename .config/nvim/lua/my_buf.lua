--! lib_buf setup and configuartion.
--! Note, that :so does not work for deletions.
local has_libbuf, libbuf = pcall(require, 'libbuf')
if not has_libbuf then return end

local actions = require 'libbuf.actions'
local state = require 'libbuf.state'

-- neovim does not store who the owner of a buffer is
local user_setup_fn = function()
  local mbuf_props = actions.currentBuffersWithPropertis()
  libbuf.annotateGroup_cliargs_init(mbuf_props)
  state._mbuf = mbuf_props
  local mbuf_h = actions.makeHandle(nil) -- unshown scratch buffer
  state.mbuf_h = mbuf_h
  libbuf.default_populateMasterBuf(mbuf_h, libbuf.default_readwrite_fn, function() end)

  -- TODO annotate initially loaded files buffers
  -- 1. if no annotation or no regular file, then mark as "init" end
  -- 2. if regular file, then mark as "pers" end
  -- 3. autocmd to mark new non-regular files as "init"
  -- 4. autocmd to mark new regular files as "open"
  -- TODO store and reload tab view
end

libbuf.delayedSetup(user_setup_fn)

local api = vim.api
local add_cmd = api.nvim_create_user_command

add_cmd('ShMBuf', function() libbuf.showMasterBuf() end, {});

add_cmd('AddDir', function() libbuf.addDir() end, {});
add_cmd('LibbufDumpState', function() state.dumpState("/tmp/state.txt") end, {});

local has_plenary, plenary = pcall(require, 'plenary')
if has_plenary == false then return end
add_cmd('AddFile', function() libbuf.addFile(plenary.path:new(api.nvim_buf_get_name(0)):make_relative()) end, {});
add_cmd('AddDirAndFile', function() libbuf.addDirAndFile(plenary.path:new(api.nvim_buf_get_name(0)):make_relative()) end, {});

