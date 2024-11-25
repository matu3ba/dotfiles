--! Formatting and conform.nvim config
-- luacheck: globals vim
-- luacheck: no max line length
-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
-- vim.api.nvim_call_function("stdpath", { "cache" })

local has_conform, conform = pcall(require, 'conform')
if not has_conform then return end
-- local util = conform.util

-- ruff_format: no cmd for combined linting and fmt yet https://github.com/astral-sh/ruff/issues/8232
-- stylua: cargo install stylua --features lua52
local fmts_by_ft = {
  -- lsp_format = 'never(default)|fallback|prefer|first|last'
  -- cmake = { 'cmake_format' },
  c = { 'clang-format' }, -- // clang-format off|on
  cpp = { 'clang-format' }, -- // clang-format off|on
  lua = { 'stylua' }, -- stylua: ignore start|end
  python = { 'ruff_format' }, -- # fmt: off|on, # fmt: skip
  rust = { 'rustfmt', lsp_format = 'prefer' },
  sh = { 'shfmt' },
  shtml = { 'superhtml' },
  -- zig = { 'zigfmt', lsp_format = 'prefer' },
  -- zig = { lsp_format = 'prefer' },
  ziggy = { 'ziggy' },
  ziggy_schema = { 'ziggy_schema' },
  -- ['*'] = { 'typos' },
  ['_'] = { 'trim_whitespace', 'trim_newlines' },
}

local pattern_most = {
  '*.h',
  '*.hh',
  '*.c',
  '*.cc', -- c
  '*.cmake',
  '*.hpp',
  '*.cpp', -- cpp
  '*.lua', -- lua
  '*.py', -- python
  '*.rs', -- rust
  '*.sh', -- sh
  '*.shtml', -- shtml
  -- no file endings .zig, .zon
}

conform.setup {
  -- additional / custom formatter
  formatters = {
    superhtml = {
      inherit = false,
      command = 'superhtml',
      stdin = true,
      args = { 'fmt', '--stdin' },
    },
    ziggy = {
      inherit = false,
      command = 'ziggy',
      stdin = true,
      args = { 'fmt', '--stdin' },
    },
    ziggy_schema = {
      inherit = false,
      command = 'ziggy',
      stdin = true,
      args = { 'fmt', '--stdin-schema' },
    },
  },

  formatters_by_ft = fmts_by_ft,
}

-- local aucmds_basicfmt = vim.api.nvim_create_augroup('aucmds_basicfmt', { clear = true })
local aucmds_conform_fmt = vim.api.nvim_create_augroup('aucmds_conform_fmt', { clear = true })
local aucmds_zig_fmt = vim.api.nvim_create_augroup('aucmds_zig_fmt', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = aucmds_conform_fmt,
  pattern = pattern_most,
  callback = function(args) conform.format { bufnr = args.buf } end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = aucmds_zig_fmt,
  pattern = { '*.zig', '*.zon' },
  callback = function()
    vim.lsp.buf.code_action {
      -- SHENNANIGAN lsp.CodeActionContext: diagnostics field is optional,
      -- but shown as error by lsp from meta information
      context = { only = { 'source.fixAll' } },
      apply = true,
    }
    vim.loop.sleep(5)
    -- SHENNANIGAN conform.nvim can screw up formatting the first time
    vim.lsp.buf.format()
  end,
})

-- markdown, supermd not handled in trim_whitespace
-- local MustNotRemoveTrailingLines = function(filetype)
--   -- or fmts_by_ft[filetype] ~= nil
--   if filetype == 'markdown' or filetype == 'supermd' then
--     return true
--   else
--     return false
--   end
-- end

-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = aucmds_basicfmt,
--   pattern = '*',
--   callback = function(args)
--     -- if MustNotRemoveTrailingLines(vim.bo.filetype) then return end
--     conform.format { bufnr = args.buf }
--     -- local view = vim.fn.winsaveview()
--     -- vim.cmd [[%s/\v\s+$//e]] -- remove trailing spaces
--     -- vim.fn.winrestview(view)
--     --vim.api.nvim_command [[:keepjumps keeppatterns %s/\s\+$//e]] -- remove trailing spaces
--   end,
-- })

-- unused: very verbose
-- local has_plenary, plenary = pcall(require, 'plenary')
-- if has_plenary then
--   -- Runs clangfmt on the whole file.
--   local clangfmt = function()
--     if vim.bo.modified then
--       local abs_fname = vim.api.nvim_buf_get_name(0)
--       for dir in vim.fs.parents(abs_fname) do
--         local abs_clangfmt = dir .. "/.clang-format"
--         local fh = io.open(abs_clangfmt, "r")
--         local file_exists = fh ~= nil
--         if file_exists then
--           io.close(fh)
--           local cursor_pos = vim.api.nvim_win_get_cursor(0)
--           local content = vim.api.nvim_buf_get_lines()
--           local plenary_run = plenary.job:new { command = 'clang-format', args = { "-i", abs_fname } }
--           local result = plenary_run:sync()
--           -- result checking etc
--           vim.api.nvim_buf_set_lines(result)
--           if plenary_run.code ~= 0 then print [[clangfmt had warning or error. Run ':%!clang-format']] end
--           vim.api.nvim_win_set_cursor(0, cursor_pos)
--           return
--         end
--       end
--     end
--   end
--   vim.api.nvim_create_autocmd('BufWritePre', {
--   group = 'DEPRECATED_MYAUCMDS', pattern = { '*.h', '*.hpp', '*.c', '*.cpp' },
--   callback = function() clangfmt() end})
-- end

-- unused conform formatter for 'conform.setup'
-- clang_format = function()
--   local cwd = assert(vim.loop.cwd())
--   -- find path/.clang-format
--   for dir in vim.fs.parents(cwd) do
--     local fh = io.open(dir, "r")
--     if (fh) then
--       fh.close(fh)
--       -- verbatim copy of conform.nvim/lua/conform/formatters/clang-format.lua
--       ---@type conform.FileFormatterConfig
--       return {
--         meta = {
--           url = "https://www.kernel.org/doc/html/latest/process/clang-format.html",
--           description = "Tool to format C/C++/… code according to a set of rules and heuristics.",
--         },
--         command = "clang-format",
--         args = { "-assume-filename", "$FILENAME" },
--         range_args = function(_, ctx)
--           local start_offset, end_offset = util.get_offsets_from_range(ctx.buf, ctx.range)
--           local length = end_offset - start_offset
--           return {
--             "-assume-filename",
--             "$FILENAME",
--             "--offset",
--             tostring(start_offset),
--             "--length",
--             tostring(length),
--           }
--         end,
--       }
--     end
--   end
--   -- unsure nil is more correct or empty table
--   return {}
-- end,

-- unused bare clang formatter
-- _G.Clangfmt = function()
--   vim.api.nvim_exec2(
--     [[
-- if &modified && !empty(findfile('.clang-format', expand('%:p:h') . ';'))
--   let cursor_pos = getpos('.')
--   :%!clang-format
--   call setpos('.', cursor_pos)
-- end
-- ]],
--     {}
--   )
-- end
-- vim.api.nvim_create_augroup('aucmds_fmt',  {clear = true})
-- vim.api.nvim_create_autocmd('BufWritePre', {group = aucmds_fmt, pattern = { '*.h', '*.hpp', '*.c', '*.cpp' }, command = [[:lua Clangfmt()]]})
