--! Dependency telescope
-- luacheck: globals vim
local ok_telescope, telescope = pcall(require, 'telescope')
if not ok_telescope then
  return --vim.notify("telescope not installed...", vim.log.ERROR)
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
    -- find_files = {
    --   mappings = {
    --     ["i"] = {
    --       ["<C-Space>"] = function(prompt_buffer)
    --         actions.close(prompt_buffer)
    --         vim.ui.input({ prompt = "glob patterns(comma sep): " }, function(input)
    --           if not input then return end
    --           require("telescope.builtin").find_files({
    --             file_ignore_patterns = vim.split(vim.trim(input), ",", { plain = true })
    --           })
    --         end)
    --       end,
    --     },
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

-- pcall on telescope extension does not work:
-- local ok_fzf, _ = pcall(require, 'fzf-native')
-- local ok_fzf, _ = pcall(require, 'fzf_lib')
-- local ok_fzf = pcall(telescope.load_extension, 'fzf_lib')
-- assert(ok_fzf)
telescope.load_extension 'gh'
-- telescope.load_extension('fzf') -- native
telescope.load_extension 'zf-native'

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

-- not working
-- telescope.load_extension 'undo'

local M = {}

M.searchStringRecentReg = function()
  local recent_copy_del_content = vim.fn.getreg '"'
  require('telescope.builtin').grep_string { search = recent_copy_del_content }
end

return M
