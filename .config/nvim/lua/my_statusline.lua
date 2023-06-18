--! Statusline with dependency plenary, gitsigns
--! Offers 1 mode: usage
--Many things copied and adjusted from
--https://github.com/kristijanhusak/neovim-config/blob/3448291f22ecfca1f6dab2f0061cbeca863664dd/nvim/lua/partials/statusline.lua
local has_plenary, plenary = pcall(require, 'plenary')
local has_gitsigns, _ = pcall(require, 'gitsigns')
if not has_plenary or not has_gitsigns then return end

local statusline = {}
local statusline_group = vim.api.nvim_create_augroup('custom_statusline', { clear = true })
vim.o.statusline = '%!v:lua.require("my_statusline").setup()'

local lsp = {
  message = '',
  printed_done = false,
}

local function print_lsp_progress()
  local message = vim.lsp.util.get_progress_messages()[1]
  if message and not lsp.printed_done then
    local percentage = message.percentage or 0
    local message_text = ''
    local percentage_text = ''
    if percentage > 0 then percentage_text = (' - %d%%%%'):format(percentage) end
    if message.message then message_text = (' (%s)'):format(message.message) end
    lsp.message = ('%s: %s%s%s'):format(message.name, message.title, message_text, percentage_text)
    if message.done then vim.defer_fn(function()
      lsp.printed_done = true
      print_lsp_progress()
    end, 300) end
  else
    lsp.message = ''
    lsp.printed_done = false
  end
end

vim.api.nvim_create_autocmd({ 'User' }, {
  group = statusline_group,
  pattern = 'LspProgressUpdate',
  callback = print_lsp_progress,
})

local function with_icon(value, icon)
  if not value then return value end
  return icon .. ' ' .. value
end

local function git_statusline()
  local result = {}
  if vim.b.gitsigns_head then
    table.insert(result, vim.b.gitsigns_head)
  elseif vim.g.gitsigns_head then
    table.insert(result, vim.g.gitsigns_head)
  end
  if vim.b.gitsigns_status then table.insert(result, vim.b.gitsigns_status) end
  if #result == 0 then return '' end
  return with_icon(table.concat(result, ' '), '')
end

local function get_path()
  -- rel_path is absolute, when path not within cwd
  -- plenary handles for us gracefully uris
  local bufname = vim.api.nvim_buf_get_name(0)
  -- neovim should always return valid path and unlist the buffer instead, but if it fails, use
  -- if bufname == nil then return "[DELETED]" end
  local rel_path = plenary.path:new(bufname):make_relative()
  if #rel_path < (vim.fn.winwidth(0) / 2) then return rel_path end
  return vim.fn.pathshorten(rel_path)
end

local function search_result()
  if vim.v.hlsearch == 0 then return '' end
  local last_search = vim.fn.getreg '/'
  if not last_search or last_search == '' then return '' end
  local searchcount = vim.fn.searchcount { maxcount = 9999 }
  return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
  -- return '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

local function get_linecol()
  local line_col_pair = vim.api.nvim_win_get_cursor(0) -- row is 1, column is 0 indexed
  return ':' .. tostring(line_col_pair[1]) .. ':' .. tostring(line_col_pair[2])
end

local function get_perc_lin()
  local curr_line = vim.api.nvim_win_get_cursor(0)[1]
  local line_count = vim.api.nvim_buf_line_count(0)
  return tostring(math.floor((curr_line / line_count) * 100)) .. '%%'
end

local function get_bufinfo()
  if vim.bo.readonly == true then return 'ro ' end
  local buf_info
  if vim.bo.buftype == '' then
    buf_info = '  '
  elseif vim.bo.buftype == 'acwrite' then
    buf_info = 'ac'
  elseif vim.bo.buftype == 'help' then
    buf_info = 'he'
  elseif vim.bo.buftype == 'nofile' then
    buf_info = '[]'
  elseif vim.bo.buftype == 'nowrite' then
    buf_info = 'nw'
  elseif vim.bo.buftype == 'quickfix' then
    buf_info = 'qf'
  elseif vim.bo.buftype == 'terminal' then
    buf_info = 'te'
  elseif vim.bo.buftype == 'prompt' then
    buf_info = 'pr'
  else
    buf_info = '  '
  end
  if vim.bo.modified then
    buf_info = buf_info .. '+'
  else
    buf_info = buf_info .. ' '
  end
  return buf_info
end

function statusline.setup()
  local path = get_path()
  local lincol = get_linecol()
  local perc_lin = get_perc_lin()
  local buf_info = get_bufinfo()
  local search = search_result()
  local git_status = git_statusline()
  local statusline_sections = {
    path,
    lincol,
    ' ',
    perc_lin,
    ' ',
    buf_info,
    ' ',
    search,
    ' ',
    git_status,
    ' ',
    lsp.message,
  }
  return table.concat(statusline_sections)
end

return statusline
