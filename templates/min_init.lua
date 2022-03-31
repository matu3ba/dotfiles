-- run with: nvim --clean -u min_init.lua main.zig

vim.o.packpath = '/tmp/nvim/site'
local plugins = {
  gitsigns = 'https://github.com/lewis6991/gitsigns.nvim',
}
local plugin_name = 'gitsigns'

for name, url in pairs(plugins) do
  local install_path = '/tmp/nvim/site/pack/test/start/'..name
  if vim.fn.isdirectory(install_path) == 0 then
    vim.fn.system { 'git', 'clone', '--depth=1', url, install_path }
  end
end

require(plugin_name).setup{
  debug_mode = true, -- You must add this to enable debug messages
}
