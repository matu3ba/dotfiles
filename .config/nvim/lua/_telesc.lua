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
    file_sorter = require('telescope.sorters').get_fzy_sorter,
  },
}
require'telescope'.load_extension('project')
--require'telescope'.load_extension'z'
require('iswap').setup{}
