-- lsp config --
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require('lspconfig').clangd.setup {} -- removed capabilities = capabilities
--require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
require('lspconfig').julials.setup {}
--require'lspconfig'.pyls.setup{ on_attach=require'completion'.on_attach }
require('lspconfig').rust_analyzer.setup { capabilities = capabilities }
require('lspconfig').texlab.setup {
  settings = {
    texlab = {
      auxDirectory = { 'build' },
      build = {
        --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' }
        --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' }
        args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' },
      },
    },
  },
}
require('lspconfig').zls.setup {} --capabilities = capabilities

--USER = vim.fn.expand '$USER'
--Sumneko_root_path = '/home/' .. USER .. '/.local/lua-language-server'
--Sumneko_binary = Sumneko_root_path .. '/bin/Linux/lua-language-server'
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
require('lspconfig').sumneko_lua.setup {
  --cmd = { Sumneko_binary, '-E', Sumneko_root_path .. '/main.lua' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- LuaJIT lua version
        path = runtime_path, --lua path
      },
      diagnostics = {
        globals = { 'vim' }, --recognize vim global
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true), -- runtime files
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
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
