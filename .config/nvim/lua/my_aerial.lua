-- luacheck: globals vim
-- luacheck: no max line length
local has_aer, aer = pcall(require, 'aerial')
if not has_aer then return end

aer.setup {
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '<' and '>'
    vim.keymap.set('n', '<', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    vim.keymap.set('n', '>', '<cmd>AerialNext<CR>', { buffer = bufnr })
  end,
}
vim.keymap.set('n', '<leader>a', '<cmd>AerialToggle!<CR>', { desc = 'Toggle Aerial' })
