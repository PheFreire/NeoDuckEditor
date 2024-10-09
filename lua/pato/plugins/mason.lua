return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    { 'j-hui/fidget.nvim', opts = {} },
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
      }
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
    -- local lsp_attach = function(client, bufnr)
    --   -- Create your keybindings here...
    -- end

    require('mason-lspconfig').setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = lsp_capabilities,
        })
      end
    })

    lspconfig.pyright.setup({
      on_attach = function(client)
      client.server_capabilities.didChangeWatchedFiles = true
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
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
