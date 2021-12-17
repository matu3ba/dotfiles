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
--require('telescope').load_extension('project_scripts')
--require('telescope').load_extension('dap')
--require('telescope').load_extension('z')
