-- lsp config --
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
require'lspconfig'.clangd.setup{} -- removed capabilities = capabilities
--require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
require'lspconfig'.julials.setup{}
--require'lspconfig'.pyls.setup{ on_attach=require'completion'.on_attach }
require'lspconfig'.rust_analyzer.setup{capabilities = capabilities}
require'lspconfig'.texlab.setup{
  settings = {
    texlab = {
      auxDirectory = {'build'},
      build = {
        --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' }
        --args = { '-pdflatex=lualatex', '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' }
        args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '-outdir=build', 'main.tex' },
      }
    }
  }
}
require'lspconfig'.zls.setup{} --capabilities = capabilities
