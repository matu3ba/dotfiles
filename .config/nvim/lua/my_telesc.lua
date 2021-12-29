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
  },
}

telescope.load_extension 'fzf'
telescope.load_extension 'project'
telescope.load_extension 'hop'
--telescope.load_extension 'command_palette'
--telescope.load_extension 'project_scripts'
--telescope.load_extension 'dap'
--telescope.load_extension 'z'
