-- local ut = require 'my_utils'

--type only file
-----@meta

local M = {}

local _key_to_index_map = {
  ['u'] = 1,
  ['i'] = 2,
  ['o'] = 3,
  ['j'] = 4,
  ['k'] = 5,
  ['l'] = 6,
}

local _index_to_key_map = {
  [1] = 'u',
  [2] = 'i',
  [3] = 'o',
  [4] = 'j',
  [5] = 'k',
  [6] = 'l',
}

local function run_command(cmd_with_args)
  local obj = vim.system(cmd_with_args, { text = true }):wait()
  assert(obj.stdout, 'FAIL: expected output, not nil')
  return obj.code == 0 and vim.trim(obj.stdout) or ''
end

local function _get_project_root()
  local jj_root = run_command { 'jj', 'root' }
  if jj_root ~= '' then return jj_root end
  local git_root = run_command { 'git', 'rev-parse', '--show-toplevel' }
  if git_root ~= '' then return git_root end
  return vim.uv.cwd()
end

local function _projects_filepath() return vim.fn.stdpath 'state' .. '/bufsl_meta.json' end

local function _project_filepath(root_dir)
  local state_dir = vim.fn.stdpath 'state'
  return state_dir .. '/puresl_' .. vim.fn.sha256(root_dir):sub(1, 16) .. '.json'
end

---@param state file state: open file handle (fd)
---@param curr_offset integer current byte offset in file Datei (control_value)
M._records_next = function(state, curr_offset)
  local sep_byte = string.byte ':'
  local newline_byte = string.byte '\n'
  state:seek('set', curr_offset)
  local chunk = state:read(1024)
  if not chunk or chunk == '' then return nil end -- EOF

  local sep_idx = nil
  local newline_idx = nil

  -- search for ':' and '\n'
  for i = 1, #chunk do
    local b = string.byte(chunk, i)
    if b == sep_byte and not sep_idx then
      sep_idx = i
    elseif b == newline_byte then
      newline_idx = i
      break
    end
  end

  if not newline_idx then newline_idx = #chunk + 1 end

  local line_len = newline_idx
  local next_offset = curr_offset + line_len

  if not sep_idx or sep_idx > newline_idx then
    return next_offset -- skip invalid line
  end

  -- offset relativ to file start
  local offset_sha = curr_offset
  local len_sha = sep_idx - 1
  local offset_path = curr_offset + sep_idx -- directly after ':'

  -- path len = line_len - len(sha) - len(\n)
  local len_path = newline_idx - sep_idx - 1
  return next_offset, offset_sha, len_sha, offset_path, len_path
end

-- Iterates file records with layout
--   shar1(len=16):payload1
--   shar2(len=16):payload2
---@param fd? file opened file descriptor
---@param start_offset integer start byte offset to start iterating, 0 for file start
---@return fun(state: file, ctrl: integer): (next_offset: integer?, offset_sha: integer?, len_sha: integer?, offset_path: integer?, len_path: integer?) iterator_fn iterator fn
---@return file fd same file handle
---@return integer? init_offset Der initiale Byte-Offset für den Schleifenstart
---
---@example
--- local proj_filepath = _projects_filepath()
--- local fd_proj = io.open(proj_filepath, 'rb') -- binary for byte offsets
--- assert(fd_proj, string.format("could not open '%s'", fd_proj))
--- local iterator_fn, fd, init_offset = M.records(fd_proj, 0)
--- -- iterations via (function, state, control) are handled by lua
--- for _next_offset, offset_sha, len_sha, offset_path, len_path in iterator_fn, fd, init_offset do
---   fd:seek('set', offset_sha)
---   local raw_sha = fd:read(len_sha)
---   fd:seek('set', offset_path)
---   local raw_path = fd:read(len_path)
---   print(string.format('SHA: %s | Path: %s (Bytes: %d-%d)', raw_sha, raw_path, offset_path, offset_path + len_path))
--- end
--- fd:close()
M.records = function(fd, start_offset)
  assert(fd, string.format '❌ FAIL: no open fd')
  return M._records_next, fd, start_offset
end

--TODO
--list projects
--list files/terms in project
--add project
--rem project
--add file/term to project, save_to_slot
--rem file/term from project, del_from_slot
--open file/term in project, jump_to_slot
--consistency check and cleanup
--leave out subcwd handling

return M
