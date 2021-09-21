require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '-uu',
    },
  },
}
require('telescope').load_extension('fzf')
require('telescope').load_extension('project')
--require('telescope').load_extension('project_scripts')
--require('telescope').load_extension('dap')
--require('telescope').load_extension('z')
