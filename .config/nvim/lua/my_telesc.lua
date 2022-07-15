local telescope = require 'telescope'

-- '-uu',
telescope.setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
    },
    -- upstream issue: https://github.com/asbjornhaland/telescope-send-to-harpoon.nvim/issues/1
    -- mappings = {
    --   i = {
    --     ["<C-h>"] = telescope.extensions.send_to_harpoon.actions.send_selected_to_harpoon
    --   },
    -- },
  },
  --extensions = {
  --  hop = {
  --    -- Highlight groups to link to signs and lines; the below configuration refers to demo
  --    -- sign_hl typically only defines foreground to possibly be combined with line_hl
  --    sign_hl = { 'WarningMsg', 'Title' },
  --    -- optional, typically a table of two highlight groups that are alternated between
  --    line_hl = { 'CursorLine', 'Normal' },
  --    -- options specific to `hop_loop`
  --    -- true temporarily disables Telescope selection highlighting
  --    clear_selection_hl = false,
  --    -- highlight hopped to entry with telescope selection highlight
  --    -- note: mutually exclusive with `clear_selection_hl`
  --    trace_entry = true,
  --    -- jump to entry where hoop loop was started from
  --    reset_selection = true,
  --  },
  --},
}

telescope.load_extension 'fzf'
telescope.load_extension 'hop'
telescope.load_extension 'gh'
--telescope.load_extension 'send_to_harpoon'
--telescope.load_extension 'urlview'

--telescope.load_extension 'project'
--telescope.load_extension 'command_palette'
--telescope.load_extension 'project_scripts'
--telescope.load_extension 'dap'
--telescope.load_extension 'z'
