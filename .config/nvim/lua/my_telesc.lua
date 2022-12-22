local ok_telescope, telescope = pcall(require, 'telescope')
if not ok_telescope then
  return
  --vim.notify("telescope not installed...", vim.log.ERROR)
end

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

local ok_fzf, _ = pcall(require, 'fzf_lib')
local ok_gh, _ = pcall(require, 'gh') -- also fails if github cli not installed
local ok_undo, _ = pcall(require, 'telescope-undo')

if ok_fzf then telescope.load_extension 'fzf' end
if ok_gh then telescope.load_extension 'gh' end
if ok_undo then telescope.load_extension 'undo' end

-- issue #6 still pending (unusable)
-- local ok_dir, _ = pcall(require, 'dir-telescope')
-- if ok_dir then telescope.load_extension 'dir' end
-- telescope.load_extension 'hop'

--telescope.load_extension 'send_to_harpoon'
--telescope.load_extension 'urlview'
--telescope.load_extension 'project'
--telescope.load_extension 'command_palette'
--telescope.load_extension 'project_scripts'
--telescope.load_extension 'dap'
--telescope.load_extension 'z'
