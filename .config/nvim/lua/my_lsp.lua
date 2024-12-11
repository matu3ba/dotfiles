--! Lsp config with lsp-zero
-- luacheck: globals vim
-- luacheck: no max line length

-- lsp protocol
-- 1. file opened in editor -> editor supposed to inform server about changes to
-- document. Builtin neovim client do that. How exactly file stored on disk
-- not important in that case.
-- SHENNANIGAN no plumbing API in neovim to do low-level fixup tasks
-- SHENNANIGAN lsp offers not a lot control
-- SHENNANIGAN neovim api is not great either with important things missing like
-- silent mode/quiet mode for non-errors

local aucmd_lsp = vim.api.nvim_create_augroup('aucmds_lsp', { clear = true })

-- clangd
-- ziggy     https://github.com/kristoff-it/ziggy
-- supermd   https://github.com/kristoff-it/supermd
-- superhtml https://github.com/kristoff-it/superhtml

--==LspInstallationsAndUsage

-- pip(x) install --upgrade ruff
-- npm install --save-dev --save-exact @biomejs/biome

-- Manual (nvim-lsp name -- mason name):
-- 'bashls', -- 'bash-language-server'
-- 'biome' -- 'biome'
-- 'jedi_language_server', -- 'jedi-language-server' prefer ruffs server
-- 'ltex', -- 'ltex-ls'
-- 'clangd', -- 'clangd'
-- 'lemminx', -- 'lemminx'
-- 'omnisharp' --  'omnisharp'
--
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

local has_lspconfig, lspconfig = pcall(require, 'lspconfig')
if not has_lspconfig then
  print 'Please install neovim/nvim-lspconfig'
  return
end

local has_lazydev, lazydev = pcall(require, 'lazydev')
if not has_lazydev then
  print 'Please install folke/lazydev.nvim'
  return
end

local has_blink, blink = pcall(require, 'blink.cmp')
if not has_blink then
  print 'Please install Saghen/blink.cmp'
  return
end

-- :lua vim.print(require('nvim-navic').is_available(0))
-- :lua vim.print(require('nvim-navic').get_data())
local has_navic, navic = pcall(require, 'nvim-navic')
if not has_navic then
  print 'Please install SmiteshP/nvim-navic'
  return
end

--==LspConfigurations

lazydev.setup {
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    'nvim-dap-ui',
  },
  -- stylua: ignore start
  enabled = function(root_dir)
    -- vim.print(root_dir) DEBUG
    return (vim.g.lazydev_enabled == nil or vim.g.lazydev_enabled)
      and (not vim.uv.fs_stat(root_dir .. '/.luarc.json'))
  end,
  -- stylua: ignore end
}

local common_capabilities = blink.get_lsp_capabilities()
local common_on_attach = function(client, bufnr)
  if client.server_capabilities.documentSymbolProvider then navic.attach(client, bufnr) end
end

-- stylua: ignore start
-- TODO https://www.reddit.com/r/neovim/comments/17j0p58/clangd_lsp_for_header_files_as_well_as_source_code/
-- SHENNANIGAN clang-fmt header reordering enabled by default in the LLVM and Chromium styles
-- clang-tidy background index clang-fmt? cross file rename
-- traverses parent dir up to find yaml file .clangd
-- CompileFlags:
--   Add: [-std=c++20]
--lspconfig.biome.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.clangd.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
--lspconfig.gopls.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
-- lspconfig.jedi_language_server.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.julials.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.omnisharp.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.ruff.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.rust_analyzer.setup { capabilities = common_capabilities, on_attach = common_on_attach, }
lspconfig.superhtml.setup{ capabilities = common_capabilities, on_attach = common_on_attach, }
-- .config/zls.json https://raw.githubusercontent.com/zigtools/zls/master/schema.json
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
    if client.workspace_folders == nil or client.workspace_folders[1] == nil then return false end
    local path = client.workspace_folders[1].name -- neovim config dir
    -- Debug common problems
    -- vim.print(client.config.settings)
    -- :lua local file = assert(io.open("tmpfile123", "a")); file:write(vim.inspect(client.config.settings) .. "\n"); file:close()

    -- :lua print(client.workspace_folders[1].name .. "\n")
    -- :lua print(tostring(not vim.uv.fs_stat(client.workspace_folders[1].name..'/.luarc.json')) .. "\n")
    -- :lua print(tostring(not vim.uv.fs_stat(client.workspace_folders[1].name..'/.luarc.jsonc')) .. "\n")

    if not vim.uv.fs_stat(path .. '/.luarc.json') and not vim.uv.fs_stat(path .. '/.luarc.jsonc') then
      -- vim.print("special client setup")
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        -- cmd = { sumneko_binary, "--logpath", "$HOME/.cache/lua-language-server/", "--metapath", "$HOME/.cache/lua-language-server/meta/"}
        diagnostics = {
          globals = { 'vim' }, -- does not work and "$HOME/.cache/lua-language-server/" does not exist
        },
        runtime = {
          version = 'LuaJIT',
        },
        workspace = {
          library = { vim.env.VIMRUNTIME },
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          -- library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
      })

      client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
    end
    return true
  end,
}

--==Keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  group = aucmd_lsp,
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- unclear if needed or not, works
    --==defaults
    -- see my_keymaps.lua for gO
    -- vim.keymap.del('v', 'gra') -- '<leader>ra'
    -- vim.keymap.del('n', 'gra') -- '<leader>rd'
    -- vim.keymap.del('n', 'gri') -- '<leader>ri'
    -- vim.keymap.del('n', 'grn') -- '<leader>rn'
    -- vim.keymap.del('n', 'grr') -- '<leader>rr'

    vim.keymap.set('n', '<leader>O', vim.lsp.buf.document_symbol, opts)
    vim.keymap.set('n', '<leader>rD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<leader>ra', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>rd', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>ri', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>rr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.signature_help, opts)

    -- switch source header in same folder: map <F4> :e %:p:s,.h$,.X123X,:s,.cpp$,.h,:s,.X123X$,.cpp,<CR>
    vim.keymap.set('n', '<leader>sh', ':ClangdSwitchSourceHeader<CR>', opts) -- switch header_source

    -- TODO use different keybindings

    --==provided with mini.bracketed
    -- vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev() end, opts) -- next error
    -- vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next() end, opts) -- previous error

    -- TODO: figure out how to solve this, because this is super annoying
    -- local bufnr = vim.api.nvim_get_current_buf()
    -- stylua: ignore start
    vim.keymap.set('n', '<leader>rf', function()
      local params = vim.lsp.util.make_range_params(0, "utf-8")
      params.context = { only = { "source.fixAll" }, triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked, diagnostics = vim.lsp.diagnostic.get_line_diagnostics(), }
      -- results is an array of lsp.CodeAction
      local diags = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
      if diags then
        for _, value0 in pairs(diags) do
          for _, value1 in pairs(value0) do
            for key2, _ in ipairs(value1) do
              if key2 > 1 then
                value1[key2] = nil
              end
            end
            -- for key2, value2 in ipairs(value1) do
            --   vim.print("key", key2)
            --   vim.print("value", value2)
            -- end
          end
        end
        -- this does not work and docs in neovim are very bad on this
        vim.lsp.buf.code_action {
          context = { diagnostics = unpack(diags), only = { "source.fixAll" }, },
          apply = true,
        }
      end
      -- vim.print(diags)
      -- context = { diagnostics = diags, only = { 'source.fixAll', triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked, } },
    end, opts)
    -- stylua: ignore end

    -- vim.keymap.set('n', 'grf', function()
    --   vim.lsp.buf.code_action {
    --     -- type annotation for missing field diagnostics is wrong, because its optional
    --     context = { only = { 'source.fixAll' } },
    --     apply = true,
    --   }
    -- end, opts)

    -- vim.keymap.set('n', '<leader>hi', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({})) end, opts)
    -- defaults with neovim release 10.0
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    vim.keymap.set('n', '<leader>ws', function() vim.lsp.buf.workspace_symbol() end, opts) -- view workspace symbols
    vim.keymap.set('n', '<leader>wf', function() vim.lsp.buf.open_float() end, opts) -- view dis
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>ql', function() vim.diagnostic.setloclist() end, opts) -- buffer diagnostics to location list
    vim.keymap.set('n', '<leader>qf', function() vim.diagnostic.setqflist() end, opts) -- all diagnostics to quickfix list
    -- vim.keymap.set('n', '<leader>fo', function() vim.lsp.buf.formatting() end, opts) -- formatting
    -- vim.keymap.set('n', '<leader>f', function()
    --   vim.lsp.buf.format { async = true }
    -- end, opts)
    -- vim.keymap.set('n', '<leader>re', function() vim.cmd#'LspRestart' end', opts) -- restart lsp
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = aucmd_lsp,
  pattern = 'ziggy',
  callback = function()
    vim.lsp.start {
      name = 'Ziggy LSP',
      cmd = { 'ziggy', 'lsp' },
      root_dir = vim.uv.cwd(),
      flags = { exit_timeout = 1000, debounce_text_changes = 150 },
    }
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = aucmd_lsp,
  pattern = 'ziggy_schema',
  callback = function()
    vim.lsp.start {
      name = 'Ziggy LSP',
      cmd = { 'ziggy', 'lsp', '--schema' },
      root_dir = vim.uv.cwd(),
      flags = { exit_timeout = 1000, debounce_text_changes = 150 },
    }
  end,
})

-- vim.api.nvim_create_autocmd('FileType', {
--   group = aucmd_lsp,
--   pattern = 'superhtml',
--   callback = function()
--     vim.lsp.start {
--       name = 'SuperHTML LSP',
--       cmd = { 'superhtml', 'lsp' },
--       root_dir = vim.uv.cwd(),
--       flags = { exit_timeout = 1000, debounce_text_changes = 150, },
--     }
--   end,
-- })

--==CompleterSetup
blink.setup {
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono',
  },
  keymap = {
    preset = 'default',
    -- Tab should only be used, if completion is active, otherwise it should
    -- be available for indentation.
    ['<Tab>'] = {},
    ['<S-Tab>'] = {},
    -- ['<C-space>'] = { 'accept', 'fallback' },
    -- ['<C-y>'] = { 'select_and_accept' },
    -- ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
    -- ['<CR>'] = { 'accept', 'fallback' },
  },
  sources = {
    completion = {
      enabled_providers = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
    },
    providers = {
      -- dont show LuaLS require statements when lazydev has items
      lsp = { fallback_for = { 'lazydev' } },
      lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
    },
  },
  -- default trigger = {},
  -- default windows = {},
  -- experimental brackets support
  -- completion = {
  --   accept = {
  --     auto_brackets = { enabled = true },
  --   },
  -- },
  -- experimental signatures support
  -- signature = { enabled = true },
}

-- cmp.setup {
--   mapping = {
--     ['<C-leader>'] = cmp.mapping.complete(),
--     ['<C-y>'] = cmp.mapping.confirm { select = true },
--     ['<C-e>'] = cmp.mapping.abort(),
--     ['<C-u>'] = cmp.mapping.scroll_docs(-4),
--     ['<C-d>'] = cmp.mapping.scroll_docs(4),
--     ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()), -- needed for unknown reasons
--     ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
--     -- C-b (back) C-f (forward) for snippet placeholder navigation. TODO not working?
--     -- ['<C-t>'] = cmp.mapping.complete({
--     --     config = {
--     --       sources = {
--     --         { name = 'tags' },
--     --       }
--     --     }
--     -- })
--     -- No selection annoyance (= 1 less keypress)
--     --['<CR>'] = cmp.mapping.confirm { -- Accept currently selected item.
--     --  behavior = cmp.ConfirmBehavior.Replace,
--     --  select = true,
--     --},
--   },
--
--   snippet = {
--     expand = function(args) vim.snippet.expand(args.body) end,
--   },
--   sources = {
--     { name = 'path' },
--     { name = 'nvim_lsp_signature_help' },
--     { name = 'nvim_lsp', keyword_length = 3 },
--     {
--       name = 'buffer',
--       keyword_length = 5,
--       option = {
--         get_bufnrs = function() return vim.api.nvim_list_bufs() end,
--       },
--     },
--   },
--   -- window = {
--   -- },
-- }
-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--
--   sources = cmp.config.sources {
--     { name = 'cmdline' },
--   },
--   matching = { disallow_symbol_nonprefix_matching = false },
-- })

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
