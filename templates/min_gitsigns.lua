for name, url in pairs{
  gitsigns = 'https://github.com/lewis6991/gitsigns.nvim',
  -- ADD OTHER PLUGINS _NECESSARY_ TO REPRODUCE THE ISSUE
} do
  local install_path = vim.fn.fnamemodify('gitsigns_issue/'..name, ':p')
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { 'git', 'clone', '--depth=1', url, install_path }
  end
  vim.opt.runtimepath:append(install_path)
end

require('gitsigns').setup{
  debug_mode = true, -- You must add this to enable debug messages
  -- ADD GITSIGNS CONFIG THAT IS _NECESSARY_ FOR REPRODUCING THE ISSUE
}

-- ADD INIT.LUA SETTINGS THAT IS _NECESSARY_ FOR REPRODUCING THE ISSUE