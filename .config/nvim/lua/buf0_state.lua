---layer0: fs operations
local M = {}

---@param state file state: open file handle (fd)
---@param curr_offset integer current byte offset in file Datei (control_value)
M._naive_records_next = function(state, curr_offset)
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
---@param fd? file opened file descriptor in binary mode
---@param start_offset integer start byte offset to start iterating, 0 for file start
---@return fun(state: file, ctrl: integer): (next_offset: integer?, offset_sha: integer?, len_sha: integer?, offset_path: integer?, len_path: integer?) iterator_fn iterator fn
---@return file fd same file handle
---@return integer? init_offset Initial Byte-Offset for loop start
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
M.naive_records = function(fd, start_offset)
  assert(fd, string.format '❌ FAIL: no open fd')
  return M._naive_records_next, fd, start_offset
end

---@param state string Comlete file content as string buffer
---@param curr_offset integer Current 0-based byte offset in buffer (control_value)
M._records_next = function(state, curr_offset)
  local start_pos = curr_offset + 1
  local newline_idx = string.find(state, '\n', start_pos, true)
  local end_pos = newline_idx or (#state + 1)
  local line_len = end_pos - start_pos
  local sep_idx = string.find(state, ':', start_pos, true)
  if not sep_idx or sep_idx > end_pos then
    return next_offset -- skip invalid line
  end
  local offset_sha = curr_offset
  local len_sha = (sep_idx - 1) - start_pos + 1
  local offset_path = sep_idx
  local len_path = (end_pos - 1) - sep_idx
  return next_offset, offset_sha, len_sha, offset_path, len_path
end

-- Iterates buffer records with layout
--   shar1(len=16):payload1
--   shar2(len=16):payload2
---@param buffer string Comlete file content as string buffer
---@param start_offset integer Start 0-byte offset to start iterating in buffer
---@return fun(state: file, ctrl: integer): (next_offset: integer?, offset_sha: integer?, len_sha: integer?, offset_path: integer?, len_path: integer?) records iterator fn
---@return buffer fd same string buffer
---@return integer? init_offset Initial byte-offset for loop start
---
---@example
--- local buf = [[
--- 0123456789abcde0:C:\code
--- 1123456789abcde1:/home/testme/
--- 2123456789abcde2:/]]
--- local next, fd, init_offset = M.records(buf, 0)
--- -- iterations via (function, state, control) are handled by lua
--- for _next_offset, offset_sha, len_sha, offset_path, len_path in records, fd, init_offset do
---   local raw_sha = string.sub(buf, offset_sha + 1, offset_sha + len_sha)
---   local raw_path = string.sub(buf, offset_path + 1, offset_path + len_path)
---   print(string.format('SHA: %s | Path: %s (Bytes: %d-%d)', raw_sha, raw_path, offset_path, offset_path + len_path))
--- end
--- fd:close()
M.records = function(buffer, start_offset)
  assert(type(buffer) == "string", "❌ FAIL: buffer must be a string")
  return M._records_next, buffer, start_offset
end

M._write_next = function(fd, offset, hash, payload)
  assert(#sha == 16, '')
  local record = sha .. ':' .. payload .. '\n'
  fd:write(record)
  return offset + #record
end

-- Writes file records with layout starting at start_offset
--   sha(len=16):payload
---@param fd file opened file descriptor in binary mode
---@param start_offset integer start byte offset to start iterating, 0 for file start
---@return fun(fd: file, offset: integer, hash: string, payload: string): integer write writer function
---@return file fd same file handle
---@return integer start_offset same start_offset now applied by fd:seek 'set'
---
---@example
--- local proj_filepath = _projects_filepath()
--- local fd_proj = io.open(proj_filepath, 'rb') -- binary for byte offsets
--- assert(fd_proj, string.format("could not open '%s'", proj_filepath))
--- local write, fd, offset = M.writer(fd_proj, 0)
---
--- -- sequentially write or update records while tracking the moving offset
--- offset = write(fd, offset, '0123456789abcde0', [[C:\code]])
--- fd:flush() -- before reading, flush to disk
--- -- some read operation
--- offset = write(fd, offset, '1123456789abcde1', '/home/testme/')
--- offset = write(fd, offset, '2123456789abcde2', '/')
--- fd:close()
M.writer = function(fd, start_offset)
  assert(fd, string.format '❌ FAIL: no open fd')
  fd:seek('set', start_offset)
  return M._write_next, fd, start_offset
end

return M
