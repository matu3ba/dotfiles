--! lib_buf setup and configuartion.
local has_libbuf, libbuf = pcall(require, 'libbuf')
if not has_libbuf then return end

local user_setup_fn = function()
  -- TODO annotate initially loaded files buffers
  -- 1. if no annotation or no regular file, then mark as "init" end
  -- 2. if regular file, then mark as "pers" end
  -- 3. autocmd to mark new non-regular files as "init"
  -- 4. autocmd to mark new regular files as "open"
  -- TODO store and reload tab view
end

libbuf.delayedSetup(user_setup_fn)
