-- lsp config with lsp-zero --
local has_lspzero, lsp = pcall(require, 'lsp-zero')
if not has_lspzero then
  -- vim.notify("lsp-zero not installed...", vim.log.ERROR)
  return
end
lsp.preset('recommended')

lsp.ensure_installed({
  "lua_ls", -- lua-language-server
  "clangd", -- clangd
  "neocmake", -- neocmakelsp
  "lemminx", -- lemminx
  "bashls", -- bash-language-server
  "jedi_language_server", -- jedi-language-server
  "ltex", -- ltex-ls
})

local has_cmp, cmp = pcall(require, 'cmp')
local has_lspconfig, _ = pcall(require, 'lspconfig')
if not has_cmp or not has_lspconfig then
  print('Please install hrsh7th/nvim-cmp and neovim/nvim-lspconfig')
  return
end

-- local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    -- ['<C-t>'] = cmp.mapping.complete({
    --     config = {
    --       sources = {
    --         { name = 'tags' },
    --       }
    --     }
    -- })
    -- No selection annoyance (= 1 less keypress)
    --['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item.
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}
  -- switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
  vim.keymap.set('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts) -- switch header_source
  vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts) -- **g**oto definition
  vim.keymap.set('n', 'gr', function() vim.lsp.buf.rename() end, opts) -- **g**oto rename
  vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts) -- Kuckstu definition
  -- vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev() end, opts) -- next error
  -- vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next() end, opts) -- previous error
  vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts) -- view workspace symbols
  vim.keymap.set('n', '<leader>vd', function() vim.lsp.buf.open_float() end, opts) -- view dis
  vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, opts) -- code action
  vim.keymap.set('n', '<leader>rf', function() vim.lsp.buf.references() end, opts) -- references
  vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts) -- restart lsp

  vim.keymap.set('n', '<leader>cd', function() vim.lsp.diagnostic.show_line_diagnostics() end, opts) -- line diagnostics
  vim.keymap.set('n', '<leader>fo', function() vim.lsp.buf.formatting() end, opts) -- formatting
  --vim.keymap.set('n', '<leader>re', function() vim.cmd#'LspRestart' end', opts) -- restart lsp
  vim.keymap.set('n', '<leader>ql', function() vim.diagnostic.setloclist() end, opts) -- buffer diagnostics to location list
  vim.keymap.set('n', '<leader>qf', function() vim.diagnostic.setqflist() end, opts) -- all diagnostics to quickfix list
  --vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, opts)
end)

lsp.configure('zls', {force_setup = true})
lsp.setup()

-- modify defaults of VonHeikemen/lsp-zero.nvim 0b312c34372ec2b0daec722d1b7fad77b84bef5b:
-- 1. get completion from all buffers
local cmp_config = lsp.defaults.cmp_config({
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp', keyword_length = 3},
    {name = 'luasnip', keyword_length = 2},
    {
      name = 'buffer',
      keyword_length = 5,
      option = {
        get_bufnrs = function ()
          return vim.api.nvim_list_bufs()
        end
      },
    },
  },
})

cmp.setup(cmp_config)


cmp.setup.cmdline(':', {

  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources(
  {
    { name = 'cmdline' },
  }),
})

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true
-- require('lspconfig').clangd.setup {} -- removed capabilities = capabilities
-- --require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
-- require('lspconfig').julials.setup {}
-- --require'lspconfig'.pyls.setup{ on_attach=require'completion'.on_attach }
-- require('lspconfig').rust_analyzer.setup { capabilities = capabilities }
-- require('lspconfig').texlab.setup {
--   settings = {
--     texlab = {
--       auxDirectory = { 'build' },
--       build = {
--         --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' }
--         --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' }
--         args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' },
--       },
--     },
--   },
-- }
-- require('lspconfig').zls.setup {} --capabilities = capabilities

--USER = vim.fn.expand '$USER'
--Sumneko_root_path = '/home/' .. USER .. '/.local/lua-language-server'
--Sumneko_binary = Sumneko_root_path .. '/bin/Linux/lua-language-server'
--local runtime_path = vim.split(package.path, ';')
--table.insert(runtime_path, 'lua/?.lua')
--table.insert(runtime_path, 'lua/?/init.lua')
--require('lspconfig').sumneko_lua.setup {
--  --cmd = { Sumneko_binary, '-E', Sumneko_root_path .. '/main.lua' },
--  settings = {
--    Lua = {
--      runtime = {
--        version = 'LuaJIT', -- LuaJIT lua version
--        path = runtime_path, --lua path
--      },
--      diagnostics = {
--        globals = { 'vim' }, --recognize vim global
--      },
--      workspace = {
--        library = vim.api.nvim_get_runtime_file('', true), -- runtime files
--      },
--      telemetry = {
--        enable = false,
--      },
--    },
--  },
--}
-- Jump directly to the first available definition every time.
--vim.lsp.handlers["textDocument/definition"] = function(_, result)
--  if not result or vim.tbl_isempty(result) then
--    print "[LSP] Could not find definition"
--    return
--  end
--
--  if vim.tbl_islist(result) then
--    vim.lsp.util.jump_to_location(result[1], "utf-8")
--  else
--    vim.lsp.util.jump_to_location(result, "utf-8")
--  end
--end
