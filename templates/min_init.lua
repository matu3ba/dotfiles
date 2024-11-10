-- run with: nvim --clean -u min_init.lua main.zig
-- vim.o.packpath = "/tmp/nvim/site"
-- local plugins = {
--   gitsigns = "https://github.com/lewis6991/gitsigns.nvim",
-- }
-- local plugin_name = "gitsigns"
--
-- for name, url in pairs(plugins) do
--   local install_path = "/tmp/nvim/site/pack/test/start/" .. name
--   if vim.fn.isdirectory(install_path) == 0 then
--     vim.fn.system({ "git", "clone", "--depth=1", url, install_path })
--   end
-- end
--
-- require(plugin_name).setup({
--   debug_mode = true, -- You must add this to enable debug messages
-- })

--nvim -u repro.lua
-- DO NOT change the paths and don't remove the colorscheme
local root = vim.fn.fnamemodify('./.repro', ':p')

-- set stdpaths to use .repro
for _, name in ipairs { 'config', 'data', 'state', 'cache' } do
  vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
end

-- bootstrap lazy
local lazypath = root .. '/plugins/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins
local plugins = {
  'folke/tokyonight.nvim',
  { 'stevearc/dressing.nvim', config = true },
  {
    'echasnovski/mini.bracketed',
    config = function()
      require('mini.bracketed').setup {}
      -- comment = { suffix = 'v' }, -- verbose comment
    end,
  },
  {
    'stevearc/oil.nvim',
    config = function() require('oil').setup { view_options = { show_hidden = true } } end,
  },
}
-- add any other plugins here
require('lazy').setup(plugins, {
  root = root .. '/plugins',
})

vim.cmd.colorscheme 'tokyonight'
-- add anything else here
