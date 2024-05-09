--! Lsp config with lsp-zero
-- luacheck: globals vim
-- luacheck: no max line length

--==LspInstallationsAndUsage

-- Manual (nvim-lsp name -- mason name):
-- 'bashls', -- 'bash-language-server'
-- 'jedi_language_server', -- 'jedi-language-server'
-- 'ltex', -- 'ltex-ls'
-- 'clangd', -- 'clangd'
-- 'lemminx', -- 'lemminx'
-- 'typst_lsp' -- 'typst-lsp'
-- 'tsserver'  -- 'typescript-language-server'
-- 'omnisharp' --  'omnisharp'

-- pip3 install -U --user jedi-language-server
-- pipx install jedi-language-server

-- must not use MasonInstall, not sure if MasonUpdate also breaks things
-- lsp.ensure_installed {
--   ---@diagnostic disable
--   ---@diagnostic enable
--   -- optionally with postfix disable:doesNotExist
--   -- 'lua_ls', --lua-language-server, lua_ls
--   -- 'neocmake', -- neocmakelsp
-- }

-- omnisharp needs also TODO

--==PluginChecks

-- neodev has setup in my_dap.lua
local has_neodev, neodev = pcall(require, 'neodev')
if has_neodev then
  neodev.setup {
    library = { plugins = { "nvim-dap-ui" }, types = true },
  }
end

local has_cmp, cmp = pcall(require, 'cmp')
local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not has_cmp or not has_lspconfig then
  print 'Please install hrsh7th/nvim-cmp and neovim/nvim-lspconfig'
  return
end

local has_cmpnvimlsp, cmpnvimlsp = pcall(require, 'cmp_nvim_lsp')
if not has_cmpnvimlsp then
  print 'Please install hrsh7th/cmp-nvim-lsp'
  return
end

-- :lua vim.print(require('nvim-navic').is_available(0))
-- :lua vim.print(require('nvim-navic').get_data())
local has_navic, navic = pcall(require, 'nvim-navic')
if not has_navic then
  print 'Please install SmiteshP/nvim-navic'
  return
end

-- local has_luasnip, luasnip = pcall(require, 'luasnip')
-- if not has_luasnip then
--   print 'Please install mandatory for nvim-cmp snippet provider saadparwaiz1/cmp_luasnip and L3MON4D3/LuaSnip'
--   return
-- end


--==LspConfigurations

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.textDocument.completion.completionItem.snippetSupport = true

local common_capabilities = cmpnvimlsp.default_capabilities() -- get the cmp_nvim_lsp ones

local common_on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then
    navic.attach(client, bufnr)
  end
end

-- local lsps_with_common_setup = {"clangd", "jedi_language_server", "julials", "rust_analyzer", "tsserver", "zls"}
-- Common setup function for lsps.
-- local common_setup = function(lsp)
--   lspconfig.lsp_name.setup {
--     capabilities = common_capabilities,
--     on_attach = common_on_attach,
--   }
-- end
-- for _, lsp_n in ipairs(lsps_with_common_setup) do
--   common_setup(lsp_n)
-- end

-- stylua: ignore start
-- TODO https://www.reddit.com/r/neovim/comments/17j0p58/clangd_lsp_for_header_files_as_well_as_source_code/
-- SHENNANIGAN clang-fmt header reordering enabled by default in the LLVM and Chromium styles
-- clang-tidy background index clang-fmt? cross file rename
lspconfig.clangd.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
--require'lspconfig'.gopls.setup{ on_attach=require'completion'.on_attach }
lspconfig.jedi_language_server.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.julials.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.rust_analyzer.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.tsserver.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.omnisharp.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
-- lspconfig.typst_lsp.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.zls.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
-- https://sookocheff.com/post/vim/neovim-java-ide/
-- https://javadev.org/devtools/ide/neovim/lsp/
-- https://github.com/neovim/nvim-lspconfig/issues/2386
-- https://stackoverflow.com/questions/74844019/neovim-setting-up-jdtls-with-lsp-zero-mason
-- https://github.com/mfussenegger/nvim-jdtls
-- https://www.reddit.com/r/neovim/comments/12ki16d/java_lsp_for_jdk_11/
-- https://langserver.org/, only support one https://github.com/eclipse-jdtls/eclipse.jdt.ls
-- stylua: ignore end

lspconfig.texlab.setup {
  capabilities = common_capabilities,
  on_attach = common_on_attach,
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

lspconfig.lua_ls.setup {
  on_attach = common_on_attach,
  on_init = function(client)
    if client.workspace_folders == nil or client.workspace_folders[1] == nil then
      return false
    end
    local path = client.workspace_folders[1].name -- neovim config dir
    -- Debug common problems
    -- vim.print(client.config.settings)
    -- :lua local file = assert(io.open("tmpfile123", "a")); file:write(vim.inspect(client.config.settings) .. "\n"); file:close()

    -- :lua print(client.workspace_folders[1].name .. "\n")
    -- :lua print(tostring(not vim.loop.fs_stat(client.workspace_folders[1].name..'/.luarc.json')) .. "\n")
    -- :lua print(tostring(not vim.loop.fs_stat(client.workspace_folders[1].name..'/.luarc.jsonc')) .. "\n")

    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      -- vim.print("special client setup")
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        -- cmd = { sumneko_binary, "--logpath", "$HOME/.cache/lua-language-server/", "--metapath", "$HOME/.cache/lua-language-server/meta/"}
        diagnostics = {
          globals = { 'vim' }, -- does not work and "$HOME/.cache/lua-language-server/" does not exist
        },
        runtime = {
          version = 'LuaJIT'
        },
        workspace = {
          library = { vim.env.VIMRUNTIME },
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          -- library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

--==Keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
    vim.keymap.set('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts) -- switch header_source
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev() end, opts) -- next error
    -- vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next() end, opts) -- previous error
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<leader>ws', function() vim.lsp.buf.workspace_symbol() end, opts) -- view workspace symbols
    vim.keymap.set('n', '<leader>wf', function() vim.lsp.buf.open_float() end, opts) -- view dis
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set({'n','v'}, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gR', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>ql', function() vim.diagnostic.setloclist() end, opts) -- buffer diagnostics to location list
    vim.keymap.set('n', '<leader>qf', function() vim.diagnostic.setqflist() end, opts) -- all diagnostics to quickfix list
    -- vim.keymap.set('n', '<leader>fo', function() vim.lsp.buf.formatting() end, opts) -- formatting
    -- vim.keymap.set('n', '<space>f', function()
    --   vim.lsp.buf.format { async = true }
    -- end, opts)
    -- vim.keymap.set('n', '<leader>re', function() vim.cmd#'LspRestart' end', opts) -- restart lsp
  end,
})

--==CompleterSetup
cmp.setup {
  mapping = {
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()), -- needed for unknown reasons
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
    -- C-b (back) C-f (forward) for snippet placeholder navigation. TODO not working?
    -- ['<C-t>'] = cmp.mapping.complete({
    --     config = {
    --       sources = {
    --         { name = 'tags' },
    --       }
    --     }
    -- })
    -- No selection annoyance (= 1 less keypress)
    --['<CR>'] = cmp.mapping.confirm { -- Accept currently selected item.
    --  behavior = cmp.ConfirmBehavior.Replace,
    --  select = true,
    --},
  },

  -- SHENNANIGAN required
  -- snippet = {
  --   expand = function(args)
  --     luasnip.lsp_expand(args.body)
  --   end,
  -- },
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lsp',               keyword_length = 3 },
    -- { name = 'luasnip',                keyword_length = 2 },
    {
      name = 'buffer',
      keyword_length = 5,
      option = {
        get_bufnrs = function() return vim.api.nvim_list_bufs() end,
      },
    },
  },
  -- window = {
  -- },
}
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),

  sources = cmp.config.sources {
    { name = 'cmdline' },
  },
})

-- incomplete workaround C-y for confirmation in cmd-cmpline not working
-- https://github.com/hrsh7th/nvim-cmp/issues/692
-- missing: accept should trigger the next completion
--vim.api.nvim_set_keymap('c', '<C-y>', '', {
--    callback = function()
--        cmp.confirm({ select = true })
--        -- neither working (not even adding space to complete incorrectly):
--        -- cmp.mapping.complete()
--    end,
--})