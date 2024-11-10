local has_gitsigns, gitsigns = pcall(require, 'gitsigns')
if not has_gitsigns then return end
-- gitsigns://C:/Users/USERNAME/REPO/worktrees/WORKTREE//BRANCH_NAME_P1/BRANCH_NAME_P2:UNIX_FILE_PATH
-- :Gitsigns diffthis BRANCH
-- debug_mode = true
gitsigns.setup {
  -- unchanged default settings
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']g', function()
      if vim.wo.diff then return ']g' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[g', function()
      if vim.wo.diff then return '[g' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { desc = 'Stage hunk' })
    map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { desc = 'Reset hunk' })
    map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
    map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })

    map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Unstage hunk' })
    map('n', '<leader>hp', gs.preview_hunk_inline, { desc = 'Preview hunk' })
    map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = 'Blame line' })

    map('n', '<leader>htb', gs.toggle_current_line_blame, { desc = 'Toggle cur line blame' })
    map('n', '<leader>htd', gs.toggle_deleted, { desc = 'Toggle deleted' })
    map('n', '<leader>hte', gs.toggle_linehl, { desc = 'Toggle extended' })
    map('n', '<leader>htn', gs.toggle_numhl, { desc = 'Toggle numbers' })
    map('n', '<leader>hts', gs.toggle_signs, { desc = 'Toggle signs' })
    map('n', '<leader>htw', gs.toggle_word_diff, { desc = 'Toggle word diff' })
    -- TODO diffthis with commit selection
    map('n', '<leader>hd', gs.diffthis, { desc = 'Diff this' })
    map('n', '<leader>hD', function() gs.diffthis '~' end, { desc = 'Diff this colored' })

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
  end,
}
