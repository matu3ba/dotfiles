--! Statusline with dependency plenary, gitsigns
--! Offers 1 mode: usage
-- luacheck: globals vim
-- luacheck: no max line length
local has_plenary, plenary = pcall(require, 'plenary')
local has_gitsigns, _ = pcall(require, 'gitsigns')
local has_navic, navic = pcall(require, 'nvim-navic')
if not has_plenary or not has_gitsigns then return end

local statusline = {}
vim.o.statusline = '%!v:lua.require("my_statusline").setup()'

local visual_setting_choices = {
  [1] = "nocwd",
  [2] = "cwd",
}
local visual_setting = visual_setting_choices[1]

---Set visual setting. Caller responsible to validate input
---@param setting string Corresponds to entry of visual_setting_choices.
statusline.setVisualSetting = function(setting)
  visual_setting = setting
end


-- print_lsp_progress from https://github.com/kristijanhusak/neovim-config/blob/3448291f22ecfca1f6dab2f0061cbeca863664dd/nvim/lua/partials/statusline.lua
-- local statusline_group = vim.api.nvim_create_augroup('custom_statusline', { clear = true })
-- local lsp = {
--   message = '',
--   printed_done = false,
-- }
-- local function print_lsp_progress(opts)
--   local progress_item = opts.data.result.value
--   local client = vim.lsp.get_clients({ id = opts.data.client_id })[1]
--
--   if progress_item.kind == 'end' then
--     lsp.message = progress_item.title
--     vim.defer_fn(function()
--       lsp.message = ''
--       lsp.printed_done = true
--       vim.cmd.redrawstatus()
--     end, 1000)
--     return
--   end
--
--   if progress_item.kind == 'begin' or progress_item.kind == 'report' then
--     local percentage = progress_item.percentage or 0
--     local message_text = ''
--     local percentage_text = ''
--     if percentage > 0 then percentage_text = (' - %d%%%%'):format(percentage) end
--     if progress_item.message then message_text = (' (%s)'):format(progress_item.message) end
--     lsp.message = ('%s: %s%s%s'):format(client.name, progress_item.title, message_text, percentage_text)
--     vim.cmd.redrawstatus()
--   end
-- end
-- if vim.fn.has('nvim-0.10.0') > 0 then
--   vim.api.nvim_create_autocmd({ 'LspProgress' }, {
--     group = statusline_group,
--     pattern = 'LspProgressUpdate',
--     callback = print_lsp_progress,
--   })
-- end
-- end print_lsp_progress

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

local function get_cwd(_visual_setting)
  if _visual_setting == "cwd" then
    local cwd = vim.loop.cwd()
    if cwd == nil then return "" else return cwd end
  else
    return ""
  end
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

local function get_context()
  -- idea: non-lsp context retrieval for simple languages?
  if not has_navic or not navic.is_available(0) then return '' end
  local data = navic.get_data()
  if data == nil or next(data) == nil then return '' end
  local data_1 = data[1]
  if data_1 ~= nil and data_1["name"] ~= nil then
    if data_1["icon"] ~= nil then
      return data_1["icon"] .. data_1["name"]
    else
      return data_1["name"]
    end
  else
    return ''
  end
end

-- other options
-- idea vim.diagnostic.is_enabled() with vim.diagnostic.count()
-- local mode = vim.api.nvim_get_mode().mode
-- selection range
function statusline.setup()
  local reserved_rhs = 80
  local winwidth = vim.fn.winwidth(0)
  local cwd = get_cwd(visual_setting)
  local path = get_path()
  local cwd_width = vim.fn.strdisplaywidth(cwd)
  local path_width = vim.fn.strdisplaywidth(path)
  if cwd_width + path_width + reserved_rhs > winwidth then
    path = vim.fn.pathshorten(path)
    if cwd_width + path_width + reserved_rhs > winwidth then
      cwd = ""
    end
  end

  local lincol = get_linecol()
  local perc_lin = get_perc_lin()
  local buf_info = get_bufinfo()
  local search = search_result()
  local git_status = git_statusline()
  local context = get_context()

  local cwd_draw = ""
  if cwd ~= "" then cwd_draw = cwd .. ' ' end
  local statusline_sections = {
    cwd_draw,
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
    context,
  }
  return table.concat(statusline_sections)
end

return statusline