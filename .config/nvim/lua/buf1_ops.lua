-- layer 1: project, file fns for listing, creation, deletion etc
local M = {}

local function run_command(cmd_with_args)
  local success, obj = pcall(function()
    return vim.system(cmd_with_args, { text = true }):wait()
  end)
  if not success or not obj or not obj.stdout then return '' end
  return obj.code == 0 and vim.trim(obj.stdout) or ''
end

M.get_project_root = function()
  local jj_root = run_command { 'jj', 'root' }
  if jj_root ~= '' then return jj_root end
  local git_root = run_command { 'git', 'rev-parse', '--show-toplevel' }
  if git_root ~= '' then return git_root end
  return vim.uv.cwd()
end

M.projects_filepath = function() return vim.fn.stdpath 'state' .. '/bufsl_meta.json' end

M.project_filepath = function(root_dir_filepath)
  local state_dir = vim.fn.stdpath 'state'
  return state_dir .. '/puresl_' .. vim.fn.sha256(root_dir):sub(1, 16) .. '.json'
end

M.read_file = function(filepath)
    local file, err = io.open(filepath, "rb")
    if not file then return nil, err end
    local content = file:read("*all")
    file:close()
    return content, err
end

return M
