local finders = require 'telescope.finders'
local pickers = require 'telescope.pickers'
local conf = require('telescope.config').values

local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'

local h = assert(io.popen 'bash -c "tasklist //NH //FI \'SESSIONNAME eq Console\'"')
-- local dat = h:read('*a')
local dat = {}
for line in h:lines() do
  table.insert(dat, line)
end

h:close()

-- for k,v in pairs(dat) do
--   print(k,v)
-- end
--print(dat)

local function mysplit(inputstr, sep)
  sep = sep or '%s'
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

local data = {}

for _, l in pairs(dat) do
  if #l > 0 then
    local splitt = mysplit(l)
    table.insert(data, { splitt[1], splitt[2] })
  end
end

local entry_maker2 = function(entry)
  return {
    value = entry,
    display = entry[1] .. ' - ' .. entry[2],
    ordinal = entry[1],
  }
end

local diag = function(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = 'processes',
      finder = finders.new_table {
        results = data,
        entry_maker = entry_maker2,
      },
      sorter = conf.generic_sorter(opts),
      -- previewer,
      -- attach_mappings
      attach_mappings = function(prompt_bufnr, map)
        local _ = map
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          print(vim.inspect(selection))
          --vim.api.nvim_put({ selection[1] }, "", false, true)
        end)
        return true
      end,
    })
    :find()
end

diag(require('telescope.themes').get_dropdown {})
