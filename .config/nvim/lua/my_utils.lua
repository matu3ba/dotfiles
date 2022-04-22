local M = {}

--map('v', '<leader>p', [[lua require('my_utils').preserve("p")]], opts)
--does not work as expected, from https://vi.stackexchange.com/a/34495
M.preserve = function(arguments)
    local args = string.format("keepjumps keeppatterns execute %q", arguments)
    -- local original_cursor = vim.fn.winsaveview()
    local tup_rowcol = vim.api.nvim_win_get_cursor(0) -- [1],[2] = y,x = row,col
    local line = tup_rowcol[1]
    local col = tup_rowcol[2] -- 0 indexed => use +1
    vim.api.nvim_command(args)
    local lastline = vim.fn.line("$")
    -- vim.fn.winrestview(original_cursor)
    if line > lastline then
        line = lastline
    end
    vim.api.nvim_win_set_cursor(0, { line, col })
end

return M
