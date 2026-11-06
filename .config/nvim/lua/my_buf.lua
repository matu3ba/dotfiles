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

-- <500 project entries, <30 entries per project => sorting not necessary
-- layer 0: state: read-iterators, writer
-- * hash:payload
-- layer 1: project, file fns for listing, creation, deletion etc
-- layer 2: high level concepts for what happens when i create project, add/delete file/shell to project
-- layer 3: keybindings

-- M.list_projects
-- M.list_items
-- M.add_project
-- M.rem_project
-- M.add_item
-- M.rem_item
-- M.open_item
-- M.check_consistency
-- M.ensure_consistency

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
