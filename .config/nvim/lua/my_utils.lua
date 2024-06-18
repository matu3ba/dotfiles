--! Dependency free functions
-- luacheck: globals vim
-- luacheck: no max line length
-- see minimal_config
local M = {}

M.isRemoteSession = function()
  local sty = vim.env.STY
  return sty ~= nil and sty == '' -- fork expensive in cygwin
end
-- let g:remoteSession = ($STY == "")

M.isWSL = function()
  return vim.fn.has 'wsl' == 1
end

-- Taken from stolen from cseickel on reddit.
---The file system path separator for the current platform.
M.path_separator = '/'
M.is_windows = vim.fn.has 'win32' == 1 or vim.fn.has 'win32unix' == 1
if M.is_windows == true then M.path_separator = '\\' end

--====utf utf8 utf16
-- vim.str_utfindex and vim.str_byteindex

---Split string into a table of strings using a separator.
---@param inputString string The string to split.
---@param sep string The separator to use.
---@return table table A table of strings.
M.pathSplit = function(inputString, sep)
  local fields = {}

  local pattern = string.format('([^%s]+)', sep)
  local _ = string.gsub(inputString, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

---Joins arbitrary number of paths together.
---@param ... string The paths to join.
---@return string
M.pathJoin = function(...)
  local args = { ... }
  if #args == 0 then return '' end

  local all_parts = {}
  if type(args[1]) == 'string' and args[1]:sub(1, 1) == M.path_separator then all_parts[1] = '' end

  for _, arg in ipairs(args) do
    local arg_parts = M.pathSplit(arg, M.path_separator)
    vim.list_extend(all_parts, arg_parts)
  end
  return table.concat(all_parts, M.path_separator)
end

M.appDateLog = function(content)
  local current_date = os.date '%Y%m%d' -- year month day according to strftime
  local fp = assert(io.open((current_date .. '.log'), 'a'))
  fp:write(content)
  fp:close()
end

-- get current line payload
M.getCurrLinePl = function()
  local linenr = vim.api.nvim_win_get_cursor(0)[1]
  return vim.api.nvim_buf_get_lines(0, linenr - 1, linenr, false)[1]
end

-- get current line payload + NL
M.getCurrLinePlNL = function() return M.getCurrLinePl() .. '\n' end

-- M.windowing = function()
--   local nr_wins = #vim.api.nvim_list_wins()
--   local ref = 2
--   if nr_wins ~= ref then return end
--   local cur_win = nvim_get_current_win()
--   vim.api.nvim_set_current_win(winid)
--   print(#vim.api.nvim_list_wins())
-- end

--map('v', '<leader>p', [[lua require('my_utils').preserve("p")]], opts)
--does not work as expected, from https://vi.stackexchange.com/a/34495
M.preserve = function(arguments)
  local args = string.format('keepjumps keeppatterns execute %q', arguments)
  -- local original_cursor = vim.fn.winsaveview()
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local line = tup_rowcol[1]
  local col = tup_rowcol[2] -- 0 indexed => use +1
  vim.api.nvim_command(args)
  local lastline = vim.fn.line '$'
  -- vim.fn.winrestview(original_cursor)
  if line > lastline then line = lastline end
  vim.api.nvim_win_set_cursor(0, { line, col })
end

M.dump = function(...)
  local objects = vim.tbl_map(vim.inspect, { ... })
  print(unpack(objects))
  return ...
end

-- TODO understand lua print(vim.inspect(package.loaded, { depth = 1 }))
-- to unload commands, mappings + relevant plugin symbols
-- https://neovim.discourse.group/t/reload-init-lua-and-all-require-d-scripts/971/15
M.reloadconfig = function()
  local luacache = (_G.__luacache or {}).cache
  for pkg, _ in pairs(package.loaded) do
    if pkg:match '^my_.+' then
      print(pkg)
      package.loaded[pkg] = nil
      if luacache then luacache[pkg] = nil end
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify('Config reloaded!', vim.log.levels.INFO)
end

M.makeScratch = function(scratchpath)
  local buf = vim.api.nvim_create_buf(true, true) -- listed, scratch: nomodified, nomodeline
  vim.api.nvim_win_set_buf(0, buf)
end

-- M.makeFileScratch = function(filepath)
--   local uri = vim.uri_from_fname(filepath)
--   local bufnr = vim.uri_to_bufnr(uri)
--   vim.bo[bufnr].bufhidden = ""
--   vim.bo[bufnr].buflisted = true
--   vim.bo[bufnr].buftype = ""
--   vim.bo[bufnr].readonly = false
--   vim.bo[bufnr].swapfile = false
-- end

M.makeFileScratch = function(filepath)
  --M.makeNamedScratch = function(filepath, scratchname)
  -- local bufs = vim.api.nvim_list_bufs()
  --for i, v in ipairs(bufs) do
  --  if(vim.api.nvim_buf_get_name(v) == "abspath_tocompare") then
  --    print("matching comparison")
  --  end
  --  print(k, ", ", v)
  --end
  local uri = vim.uri_from_fname(filepath)
  local bufnr = vim.uri_to_bufnr(uri)
  vim.bo[bufnr].bufhidden = ''
  vim.bo[bufnr].buflisted = true
  vim.bo[bufnr].buftype = ''
  vim.bo[bufnr].readonly = false
  vim.bo[bufnr].swapfile = false
  return true
end

-- ###### Notes for terminal stuff ######
-- vim.api.nvim_command('botright split new') -- split a new window (no lua api yet)
-- vim.api.nvim_win_set_height(0, 30) -- set the window height
-- local win_handle = vim.api.nvim_tabpage_get_win(0) -- get the window handler
-- local buf_handle = vim.api.nvim_win_get_buf(0) -- get the buffer handler
-- jobID = vim.api.nvim_call_function("termopen", {"$SHELL"})
-- vim.api.nvim_buf_set_option(buf_handle, 'modifiable', true)
-- vim.api.nvim_buf_set_lines(buf_handle, 0, 0, true, {"ls"})
-- nvim_get_channel_info(&channel).pty

-- https://github.com/sar/neogit.nvim/blob/2b89410f77947838a7e79ec90ed6075e51846dc1/lua/neogit/process.lua#L101
-- scroll to end

-- vim.env does not contain all environment variables, for example EDITOR is missing
-- vim.env.CMDLOG = 'bar'
-- print(vim.env.CMDLOG) -- called from subshells, however works

M.printPairsToTmp = function(table)
  local fp = assert(io.open('/tmp/tmpfile', 'a'))
  for key, value in pairs(table) do
    fp:write(key)
    fp:write ', '
    fp:write(value)
    fp:write '\n'
  end
  fp:close()
end

M.printIpairsToTmp = function(table)
  local fp = assert(io.open('/tmp/tmpfile', 'a'))
  for index, value in ipairs(table) do
    fp:write(index)
    fp:write ', '
    fp:write(tostring(value))
    fp:write '\n'
  end
  fp:close()
end

M.Print = function(v)
  print(vim.inspect(v))
  return v
end

M.listpackages = function()
  -- buf_open_scratch is missing in vim.api
  -- local bufnr = vim.api.nvim_create_buf(true, true)
  -- print(bufnr)
  -- vim.api.nvim_open_win(bufnr, 0, win_opts)
  vim.api.nvim_command 'enew'
  local contents = {}
  for pkg, _ in pairs(package.loaded) do
    table.insert(contents, pkg)
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, true, contents)
end

M.reloadModule = function(module)
  for pkg, _ in pairs(package.loaded) do
    if pkg:match('^' .. module) then
      package.loaded[pkg] = nil
      require(pkg)
    end
  end
  vim.notify('Module ' .. module .. ' reloaded!', vim.log.levels.INFO)
end

--- Copy forward/backwards until first occurence of same symbol into register
-- without match, a message is printed
-- @param backwards boolean if search is forwards or backwards
-- @param register register where content is copied to
--
-- map('n', '-', ':lua require("my_utils").CopyMatchingChar(false, [[""]])<CR>', opts)
-- map('n', '_', ':lua require("my_utils").CopyMatchingChar(true, [[""]])<CR>', opts)
M.CopyMatchingChar = function(backwards, register)
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local crow = tup_rowcol[1]
  local ccol = tup_rowcol[2] -- 0 indexed => use +1
  local cchar = vim.api.nvim_get_current_line():sub(ccol + 1, ccol + 1)
  local matchchar = {
    ['('] = ')',
    [')'] = '(',
    ['{'] = '}',
    ['}'] = '{',
    ['['] = ']',
    [']'] = '[',
    ['<'] = '>',
    ['>'] = '<',
    ['"'] = '"',
    ["'"] = "'",
    ['|'] = '|',
    ['`'] = '`',
    ['/'] = '/',
    ['\\'] = '\\',
  }
  -- note searchpos: stopline only works forwards
  -- => flag 'b' is not using starting line
  local tup_search
  if backwards == false then
    tup_search = vim.fn.searchpos(matchchar[cchar], 'nz', crow + 1) -- +1 to search until next line?
  else
    tup_search = vim.fn.searchpos(matchchar[cchar], 'bnz') -- +1 to search until next line?
  end
  local srow = tup_search[1]
  local scol = tup_search[2]
  if srow == 0 and scol == 0 and backwards == false then
    print 'no matching forward character'
    return
  end
  if (srow == 0 and scol == 0 and backwards == true) or srow ~= crow or (backwards == true and ccol < scol) then
    print 'no matching backwards character'
    return
  end
  local copytext
  if backwards == false then
    copytext = vim.api.nvim_get_current_line():sub(ccol + 1, scol)
    print(string.format([[%s %s:%s]], [[write -> into]], register, copytext))
  else
    copytext = vim.api.nvim_get_current_line():sub(scol, ccol + 1)
    print(string.format([[%s %s:%s]], [[write <- into]], register, copytext))
  end
  vim.fn.setreg(register, copytext)
end

-- Keep cursor and join next line without empty space, if existing
M.joinRemoveBlank = function()
  -- SHENNANIGAN: '<', '>' still advertised as cursor positions, but its only extmarks
  -- cursor positions are 'v' for first and '.' for last selectio positions
  local vstart = vim.fn.getpos("v") -- bufnum, lnum, col, off
  local vend = vim.fn.getpos(".")
  if vstart[2] == vend[2] then
    local line_content = vim.api.nvim_get_current_line()
    local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
    local crow = tup_rowcol[1] -- 1 indexed
    local nextline = vim.api.nvim_buf_get_lines(0, crow, crow + 1, true)
    vim.api.nvim_buf_set_lines(0, crow, crow + 1, true, {})
    local nextline_noprepostfix_space = vim.fn.trim(nextline[1], " ", 0)
    local nextline_noprepostfix_spacetab = vim.fn.trim(nextline_noprepostfix_space, '\t', 0)
    vim.api.nvim_set_current_line(line_content .. nextline_noprepostfix_spacetab)
  else
    local line_content = vim.api.nvim_buf_get_lines(0, vstart[2] - 1, vstart[2], true)
    local nextlines = vim.api.nvim_buf_get_lines(0, vstart[2], vend[2], true)
    vim.api.nvim_buf_set_lines(0, vstart[2], vend[2], true, {})
    for i = 1, #nextlines, 1 do
      nextlines[i] = vim.fn.trim(nextlines[i], ' ', 0)
      nextlines[i] = vim.fn.trim(nextlines[i], '\t', 0)
      line_content[1] = line_content[1] .. nextlines[i]
    end
    vim.api.nvim_buf_set_lines(0, vstart[2] - 1, vstart[2], true, { line_content[1] })
    vim.api.nvim_win_set_cursor(vstart[1], {vstart[2], vstart[3]})
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), 'x', false)
  end
end


-- starting at cursor: overwrite text to right with register content
-- keep_suffix defines, if remaining line suffix should be kept
M.pasteOverwriteFromRegister = function(register, keep_suffix)
  local line_content = vim.api.nvim_get_current_line()
  local reg_content = vim.fn.getreg(register)
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local col_nr = tup_rowcol[2] -- 0 indexed => use +1
  local col = col_nr + 1
  local reg_len = string.len(reg_content)
  local line_len = string.len(line_content)
  local prefix = string.sub(line_content, 1, col - 1) -- until before cursor
  local suffix = string.sub(line_content, col + reg_len, line_len) -- starting at cursor
  if keep_suffix == true then
    vim.api.nvim_set_current_line(prefix .. reg_content .. suffix)
  else
    vim.api.nvim_set_current_line(prefix .. reg_content)
  end
end

--====macros
-- In registers for macros, special characters like ESC and ENTER are replaced
-- with the Vim representation ^[ and ^M respectively.
local lut_index_to_reg = {
  [1 ]  = '"', [2 ]  = '0', [3 ]  = '1', [4 ]  = '2', [5 ]  = '3',
  [6 ]  = '4', [7 ]  = '5', [8 ]  = '6', [9 ]  = '7', [10]  = '8',
  [11] = '9', [12] = 'a', [13] = 'b', [14] = 'c', [15] = 'd',
  [16] = 'e', [17] = 'f', [18] = 'g', [19] = 'h', [20] = 'i',
  [21] = 'j', [22] = 'k', [23] = 'l', [24] = 'm', [25] = 'p',
  [26] = 'q', [27] = 'r', [28] = 's', [29] = 't', [30] = 'u',
  [31] = 'v', [32] = 'w', [33] = 'x', [34] = 'y', [35] = 'z',
  [36] = '-', [37] = '*', [38] = '+', [39] = '.', [40] = ':',
  [41] = '%', [42] = '#', [43] = '/',
}
-- translates index to register, returns nil without match
M.indexToRegister = function(index)
  return lut_index_to_reg[index]
end

local lut_reg_to_index = {
  ['"'] = 1, ['0'] = 2, ['1'] = 3, ['2'] = 4, ['3'] = 5,
  ['4'] = 6, ['5'] = 7, ['6'] = 8, ['7'] = 9, ['8'] = 10,
  ['9'] = 11, ['a'] = 12, ['b'] = 13, ['c'] = 14, ['d'] = 15,
  ['e'] = 16, ['f'] = 17, ['g'] = 18, ['h'] = 19, ['i'] = 20,
  ['j'] = 21, ['k'] = 22, ['l'] = 23, ['m'] = 24, ['p'] = 25,
  ['q'] = 26, ['r'] = 27, ['s'] = 28, ['t'] = 29, ['u'] = 30,
  ['v'] = 31, ['w'] = 32, ['x'] = 33, ['y'] = 34, ['z'] = 35,
  ['-'] = 36, ['*'] = 37, ['+'] = 38, ['.'] = 39, [':'] = 40,
  ['%'] = 41, ['#'] = 42, ['/'] = 43,
}

-- translates register to index, returns nil without match
M.registerToIndex = function(register)
  return lut_reg_to_index[register]
end

-- SHENNANIGAN no vim/neovim docs on how multple newlines should be serialized and i
-- deserialized to be visualized on 1 line.

-- Parse buffer to registers, filepath format:
--   REGISTERNAME REGISTERCONTENT
--   a registercontent
--   b registercontent
-- If filepath is nil, then current buffer is used.
M.parseBufferToRegisters = function(bufnr)
  if bufnr == nil then
    bufnr = 0
  end
  for crow = 1, #lut_index_to_reg do
    local lines = vim.api.nvim_buf_get_lines(bufnr, crow-1, crow, false)
    if #lines == 0 then
      return
    end
    local first = string.sub(lines[1], 1, 1)
    local second = string.sub(lines[1], 2, 2)
    local content = string.sub(lines[1], 3, -1)
    -- print("first", first)
    -- print("second", second)
    if second == " " or content ~= "" then
      -- %, :, ., " register is not writable
      if first == '%' or first == ':' or first == '.' or first == '"' then
        goto continue_lut
      end
      local should_parse = lut_reg_to_index[first] ~= nil
      if (should_parse) then
        local reg = first
        local content_eom_subst_by_eol = string.gsub(content, '\025', '\r')
        -- print("crow", crow)
        -- print("reg", reg)
        -- print("content", content_eom_subst_by_eol)
        vim.fn.setreg(reg, content_eom_subst_by_eol)
      end
    end
    ::continue_lut::
  end
end

-- Dump registers to buffer, filepath format:
--   REGISTERNAME REGISTERCONTENT
--   a registercontent
--   b registercontent
-- If filepath is nil, then current buffer is used.
M.dumpRegistersToBuffer = function(registers, bufnr)
  if bufnr == nil then
    bufnr = 0
  end
  if registers == nil then
    for i = 1, #lut_index_to_reg do
       local reg_content = vim.fn.getreg(lut_index_to_reg[i])
       local reg_eol_subst_by_eom = string.gsub(reg_content, '\n', "\025")
       -- print(reg_eol_subst_by_eom)
       vim.api.nvim_buf_set_lines(bufnr, i-1, i-1, true, {lut_index_to_reg[i] .. " " .. reg_eol_subst_by_eom})
    end
  else
    for i = 1, #lut_index_to_reg do
      local should_print = registers[lut_index_to_reg[i]] ~= nil
      if should_print then
        local reg_content = vim.fn.getreg(lut_index_to_reg[i])
        local reg_eol_subst_by_eom = string.gsub(reg_content, '\n', "\025")
        -- print(reg_eol_subst_by_eom)
        vim.api.nvim_buf_set_lines(bufnr, i-1, i-1, true, {lut_index_to_reg[i] .. " " .. reg_eol_subst_by_eom})
      end
    end
  end
end

-- starting at cursor: move cursor into direction until non-space symbol
-- space symbols are [space|tab], direction can be "up" and "down"
-- overwrite text to right with register content
-- keep_suffix defines, if remaining line suffix should be kept
M.moveDirectionUntilNonSpaceSymbol = function(direction)
  local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
  local crow = tup_rowcol[1]
  local ccol = tup_rowcol[2] -- 0 indexed => use +1
  local cchar = vim.api.nvim_get_current_line():sub(ccol + 1, ccol + 1)
  local first_char = cchar
  if first_char ~= ' ' then return end
  -- TODO handle out of bounds for correct jump
  if direction == 'up' then
    while crow > 0 do
      crow = crow - 1
      cchar = vim.api.nvim_buf_get_lines(0, crow - 1, crow, false):sub(ccol + 1, ccol + 1)
      if cchar ~= first_char then break end
    end
  elseif direction == 'down' then
    local crowcount = vim.api.nvim_buf_line_count(0)
    while crow < crowcount do
      crow = crow + 1
      cchar = vim.api.nvim_buf_get_lines(0, crow - 1, crow, false):sub(ccol + 1, ccol + 1)
      if cchar ~= first_char then break end
    end
  else
    print 'invalid direction given'
  end
  vim.api.nvim_win_set_cursor(0, { crow, ccol })
end

-- better replacement: tpope/vim-abolish
-- https://github.com/vE5li/cmp-buffer
-- https://github.com/hrsh7th/cmp-buffer/compare/main...vE5li:cmp-buffer:main
M.swap_camel_and_snake_case = function(name)
  local new_name = ''
  local first_character = string.sub(name, 1, 1)

  -- is snake case
  if string.lower(first_character) == first_character then
    local next_capital = true

    for i = 1, #name do
      local character = name:sub(i, i)

      if character == '_' then
        next_capital = true
      else
        if next_capital then
          new_name = new_name .. string.upper(character)
          next_capital = false
        else
          new_name = new_name .. character
        end
      end
    end

    -- is camel case
  else
    for i = 1, #name do
      local character = name:sub(i, i)

      if string.upper(character) == character then
        if i > 1 then new_name = new_name .. '_' end
        new_name = new_name .. string.lower(character)
      else
        new_name = new_name .. character
      end
    end
  end

  return new_name
end

return M

--==minimal_config
--== -- nvim --clean -u repro_init.lua
--== local root = vim.fn.fnamemodify("./.repro", ":p")
--== -- set stdpaths to use .repro
--== for _, name in ipairs({ "config", "data", "state", "cache" }) do
--==   vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
--== end
--== -- bootstrap lazy
--== local lazypath = root .. "/plugins/lazy.nvim"
--== if not vim.loop.fs_stat(lazypath) then
--==   vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath, })
--== end
--== vim.opt.runtimepath:prepend(lazypath)
--== -- install plugins
--== local plugins = {
--==   "marko-cerovac/material.nvim",
--==   -- ^ Adjust here ^
--==      v             v
--== }
--== require("lazy").setup(plugins, {
--==   root = root .. "/plugins",
--== })
--== vim.cmd.colorscheme("material")
--== -- ^ Adjust here ^
--==    v             v