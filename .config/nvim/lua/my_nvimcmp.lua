---- nvim-cmp setup ----
local cmp = require 'cmp'
cmp.setup {
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-t>'] = cmp.mapping.complete({
        config = {
          sources = {
            { name = 'tags' },
          }
        }
      })
    -- No selection annoyance (= 1 less keypress)
    --['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item.
  },
  sources = cmp.config.sources({
    --{ name = 'buffer' },
    --{
    --  name = 'buffer',
    --  options = {
    --    get_bufnrs = function()
    --      local bufs = {}
    --      for _, win in ipairs(vim.api.nvim_list_wins()) do
    --        bufs[vim.api.nvim_win_get_buf(win)] = true
    --      end
    --      return vim.tbl_keys(bufs)
    --    end
    --  },
    --},
    { name = 'nvim_lsp' },
    -- TODO setup inbuild completions to work properly by adjusting C-n,Cp
    -- or setup vim-gutentags
    --{ name = 'tags' },
    --{ name = 'cmp_ctags' },
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }),
}

-- Set configuration for specific filetype.
--cmp.setup.filetype('gitcommit', {
--  sources = cmp.config.sources({
--    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
--  }, {
--    { name = 'buffer' },
--  })
--})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  }),
})

-- Setup lspconfig.
--local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
local lspconfig = require 'lspconfig'
lspconfig['clangd'].setup { capabilities = capabilities }
lspconfig['julials'].setup { capabilities = capabilities }
lspconfig['rust_analyzer'].setup { capabilities = capabilities }
lspconfig['texlab'].setup {
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
  capabilities = capabilities,
}
lspconfig['zls'].setup { capabilities = capabilities }
lspconfig['sumneko_lua'].setup {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      telemetry = { enable = false },
    },
  },
  capabilities = capabilities,
}
