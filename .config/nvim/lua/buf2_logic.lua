local M = {}

local bu0 = require 'buf0_state'
local bu1 = require 'buf1_ops'

M.list_projects = function()
  local buf, err = bu1.read_file(bu1.projects_filepath())
  if buf == nil then
    return 1 -- no such directory
  end
  print("buf:", buf)
  local projects = ""
  local records, buf, start_offset = bu0.records(buf, 0)
  for _next_offset, offset_sha, len_sha, offset_path, len_path in records, buf, start_offset do
    local raw_sha = string.sub(buf, offset_sha + 1, offset_sha + len_sha)
    local raw_path = string.sub(buf, offset_path + 1, offset_path + len_path)
    projects = projects .. raw_sha .. ':' .. raw_path .. '\n'
    print(string.format('SHA: %s | Path: %s (Bytes: %d-%d)', raw_sha, raw_path, offset_path, offset_path + len_path)) -- debug
  end
  return projects
end

M.add_project = function(root_dir)
  assert(vim.fs.abspath(root_dir) == root_dir, 'root_dir must be absolute path')

  local hash = vim.fn.sha256(root_dir):sub(1, 16)
  local buf, err = bu1.read_file(bu1.projects_filepath())
  assert(err == nil, string.format("can not open '%s': '%s'",bu1.projects_filepath(), err))
  local projects = ""
  local records, buf, start_offset = bu0.records(buf, 0)
  local next_offset = 0
  for _next_offset, offset_sha, len_sha, offset_path, len_path in records, buf, start_offset do
    local raw_sha = string.sub(buf, offset_sha + 1, offset_sha + len_sha)
    local raw_path = string.sub(buf, offset_path + 1, offset_path + len_path)
    if hash == raw_sha then
      assert(root_dir == raw_path)
      return 1 -- error.project_entry_already_existing
    end
    next_offset = _next_offset
    -- print(string.format('SHA: %s | Path: %s (Bytes: %d-%d)', raw_sha, raw_path, offset_path, offset_path + len_path)) -- debug
  end

  local fd, err = io.open(bu1.projects_filepath(), 'a+b')
  assert(fd, string.format("can not open '%s': '%s'",bu1.projects_filepath(), err))
  local write, fd, offset = bu0.writer(fd, next_offset)
  offset = write(fd, offset, hash, root_dir)
  fd:close()

  local proj_file = bu1.project_filepath(root_dir)
  local proj_fd = io.open(proj_file, 'w+b')
  if not proj_fd then
    return 2 -- error.project_file_already_existing
  end
  proj_fd:close()

  return 0 -- ok
end

M.rem_project = function(root_dir)
  assert(vim.fs.abspath(root_dir) == root_dir, 'root_dir must be absolute path')

  local hash = vim.fn.sha256(root_dir):sub(1, 16)
  local buf, err = bu1.read_file(bu1.projects_filepath())
  assert(err == nil)

  local found = false
  local new_buf = ""
  local next, buf_iter, start_offset = bu0.records(buf, 0)
  for _next_offset, offset_sha, len_sha, offset_path, len_path in next, buf_iter, start_offset do
    local raw_sha = string.sub(buf, offset_sha + 1, offset_sha + len_sha)
    local raw_path = string.sub(buf, offset_path + 1, offset_path + len_path)
    if hash == raw_sha then
      assert(root_dir == raw_path)
      found = true
    else
      new_buf = new_buf .. raw_sha .. ':' .. raw_path .. '\n'
    end
    -- print(string.format('SHA: %s | Path: %s (Bytes: %d-%d)', raw_sha, raw_path, offset_path, offset_path + len_path)) -- debug
  end
  if not found then
    return 1 -- error.project_entry_not_found
  end
  local fd = io.open(bu1.projects_filepath(), 'w+b')
  assert(fd, string.format("cannot open '%s'", bu1.projects_filepath()))
  fd:write(new_buf)
  fd:close()

  local proj_file = bu1.project_filepath(root_dir)
  if vim.uv.fs_stat(proj_file) then
    os.remove(proj_file)
  else
    return 2 -- error.project_file_not_existing
  end
  return 0 -- ok
end

M.check_consistency = function()
  -- TODO
  -- consistent means
  -- * all project entries have associated files
  -- * all project files are complete and have consistent fields and types

end
M.ensure_consistency = function()
  -- ensuring consistency means
  -- * create (sorted) map proj_item=[hash:status], proj_file[hash:status]
  -- * iterate once proj_item + delete projects with non-existing proj_file
  -- * iterate once all files proj_file and delete non-conform files
end

-- M.list_items
-- M.add_item
-- M.rem_item
-- M.open_item

return M
