--! Formatting and conform.nvim config
-- luacheck: globals vim
-- luacheck: no max line length
-- inspiration: https://www.reddit.com/r/neovim/comments/j7wub2/how_does_visual_selection_interact_with_executing/
-- vim.fn.expand('%:p:h'), vim.fn.expand('%:p:~:.:h'), vim.fn.fnamemodify
-- vim.api.nvim_call_function("stdpath", { "cache" })

local has_conform, conform = pcall(require, 'conform')
if not has_conform then return end
-- local util = conform.util

---ruff.toml
-- line-length = 100
-- [format]
-- quote-style = "single"
-- indent-style = "space"

-- ruff_format: no cmd for combined linting and fmt yet https://github.com/astral-sh/ruff/issues/8232
-- stylua: cargo install stylua --features lua52
-- tex-fmt: cargo install tex-fmt
local fmts_by_ft = {
  -- lsp_format = 'never(default)|fallback|prefer|first|last'
  -- cmake = { 'cmake_format' },
  -- FIXME: looks broken on windows, so check yourself for .clang-format file
  c = { 'clang-format' }, -- // clang-format off|on
  cpp = { 'clang-format' }, -- // clang-format off|on
  lua = { 'stylua' }, -- stylua: ignore start|end
  -- python = { 'ruff_format' }, -- # fmt: off|on, # fmt: skip
  rust = { 'rustfmt', lsp_format = 'prefer' },
  -- sh = { 'shfmt' }, -- go not great language
  shtml = { 'superhtml' },
  -- https://github.com/WGUNDERWOOD/tex-fmt/issues/55
  -- tex = { 'tex-fmt' }, -- % tex-fmt: off|on, % tex-fmt: skip
  zig = { 'zigfmt', lsp_format = 'prefer' },
  -- -- zig = { lsp_format = 'prefer' },
  ziggy = { 'ziggy' },
  ziggy_schema = { 'ziggy_schema' },
  -- ['*'] = { 'typos' }, -- autofix for programming bad, but useful for text only
  -- call directly, dont use ['_'] for { 'trim_whitespace', 'trim_newlines' }
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
-- local aucmds_zig_fmt = vim.api.nvim_create_augroup('aucmds_zig_fmt', { clear = true })

-- SHENNANIGAN code_action has no silent mode https://github.com/neovim/neovim/pull/22651
local user_fmts_by_ft = {
  markdown = function() end, -- stub
  supermd = function() end, -- stub
  zig = function(args)
    local original = vim.notify
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, level, opts)
      if msg == 'No code actions available' then return end
      original(msg, level, opts)
    end
    vim.lsp.buf.code_action {
      ---@diagnostic disable-next-line: missing-fields
      context = { only = { 'source.fixAll' } },
      apply = true,
    }
    conform.format { bufnr = args.buf, formatters = fmts_by_ft['zig'] }
  end,
  zon = function(args) conform.format { bufnr = args.buf, formatters = fmts_by_ft['zig'] } end,
}

vim.api.nvim_create_autocmd('BufWritePre', {
  group = aucmds_conform_fmt,
  pattern = '*',
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if user_fmts_by_ft[ft] ~= nil then
      user_fmts_by_ft[ft](args)
    else
      if fmts_by_ft[ft] == nil then
        conform.format { bufnr = args.buf, formatters = { 'trim_whitespace' } }
      else
        conform.format { bufnr = args.buf, formatters = fmts_by_ft[ft] }
      end
    end
  end,
})

-- taken from  https://github.com/neovim/neovim/issues/17758#issuecomment-2337109283
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = { "*.go" },
--     callback = function()
--         vim.lsp.buf.format()
--
--         local params = vim.lsp.util.make_range_params()
--         params.context = {only = {"source.organizeImports"}}
--         vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(responses)
--             for client_id, response in pairs(responses) do
--                 if response.result then
--                     for _, result in pairs(response.result) do
--                         if result.edit then
--                             vim.lsp.util.apply_workspace_edit(result.edit, vim.lsp.get_client_by_id(client_id).offset_encoding)
--                         else
--                             vim.lsp.buf.execute_command(result.command)
--                         end
--                     end
--                     -- This routine is async, which I like because it doesn't lock up.
--                     -- However, it doesn't complete before the write, so it needs another write.
--                     -- The below write() *can* trigger an infinite loop of BufWritePre if the language server acts up.
--                     -- See the nvim-lspconfig issue for alternatives: https://github.com/neovim/nvim-lspconfig/issues/115
--                     vim.cmd.write()
--                 end
--             end
--         end)
--     end,
-- })

-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = aucmds_zig_fmt,
--   pattern = { '*.zig', '*.zon' },
--   callback = function()
--     vim.lsp.buf.code_action {
--       -- SHENNANIGAN lsp.CodeActionContext: diagnostics field is optional,
--       -- but shown as error by lsp from meta information
--       context = { only = { 'source.fixAll' } },
--       apply = true,
--     }
--     vim.uv.sleep(5)
--     -- SHENNANIGAN conform.nvim can screw up formatting the first time
--     vim.lsp.buf.format()
--   end,
-- })

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
--   local cwd = assert(vim.uv.cwd())
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
