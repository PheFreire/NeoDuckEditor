return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    'j-hui/fidget.nvim',
    {'folke/neodev.nvim' },
  },
  config = function ()
    require('mason').setup()

    require('mason-lspconfig').setup({
      ensure_installed = {
        'matlab_ls',
        'prismals',
        'terraformls',
        'ts_ls',
        'kotlin_language_server',
        'eslint',
        'bashls',
        'cssls',
        'html',
        'lua_ls',
        'jsonls',
        'lemminx',
        'marksman',
        'quick_lint_js',
        'yamlls',
        'pyright',
        'remark_ls',
        'dockerls',
        'docker_compose_language_service',
        'taplo',
        'arduino_language_server',
        'rust_analyzer',
      },
      automatic_installation = true,
    })

    require('mason-tool-installer').setup({
      ensure_installed = {
        'black',
        'debugpy',
        'flake8',
        'isort',
        'mypy',
        'pylint',
        'rust-analyzer',
      },
    })

    vim.api.nvim_command('MasonToolsInstall')

    local lspconfig = require('lspconfig')
    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

    require('mason-lspconfig').setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = lsp_capabilities,
        })
      end
    })
    
    lspconfig.rust_analyzer.setup {
      on_attach = function(_, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
      end,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = {
            command = "clippy",
          },
          lens = {
            enable = true,
          },
        },
      }
    }

    lspconfig.pyright.setup({
      on_attach = function(client)
        if client.server_capabilities.documentFormattingProvider then
          -- código para formatação
        end
      end,
        python = {
          analysis = {
            useLibraryCodeForTypes = true,
            autoSearchPaths = true,
            diagnosticMode = "workspace",
          },
        },
    })

    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          diagnostics = { globals = {'vim'}, },
        },
      },
    }

    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      return open_floating_preview(contents, syntax, opts, ...)
    end

  end
}
