--! lib_buf setup and configuartion.
local has_libbuf, libbuf = pcall(require, 'libbuf')
if not has_libbuf then return end

local mbuf = require 'libbuf.mbuf'
local state = require 'libbuf.state'
local util = require 'libbuf.util'

-- neovim does not store who the owner of a buffer is
local user_setup_fn = function()
  -- make unlisted scratch buffer
  local mbuf_h = mbuf.makeHandle(nil)
  state.mbuf_h = mbuf_h
  -- add state about buffers other than master buffer
  local mbuf_props = util.currentBuffersWithPropertis()
  -- add annotations
  local file_args = 0
  for i, v in ipairs(vim.v.argv) do
    -- skip neovim binary name
    if i > 1 then
      -- skip options (true disables pattern matching)
      if v:find('-', 1, true) ~= 1 then
        file_args = file_args + 1
      end
    end
  end
  local fcnt = 0
  while fcnt < file_args do
    mbuf_props[fcnt+1]["group"] = "cli_args" -- tables start with 1
    fcnt = fcnt + 1
  end
  for i,_ in ipairs(mbuf_props) do
    if i > 1 then
      mbuf_props[i]["group"] = "init"
    end
  end
  state._mbuf = mbuf_props
  -- print(vim.inspect(state._mbuf))
  libbuf.default_populateMasterBuf(mbuf_h, libbuf.default_readwrite_fn, function() end)
  -- print("name, loaded, ty, ro, hidden, listed")
  -- print(vim.inspect(mbuf_props))

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

add_cmd('ShMBuf', function()
  local vim_cmd = "buffer " .. tostring(state.mbuf_h)
  vim.cmd(vim_cmd)
end, {});


add_cmd('LibbufDumpState', function()
  state.dumpState("/tmp/state.txt")
end, {});
