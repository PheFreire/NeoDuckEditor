return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    'j-hui/fidget.nvim',
    { 'folke/neodev.nvim' },
  },
  config = function()
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
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local uv = vim.loop

    local function has_src_dir(root_dir)
      local stat = uv.fs_stat(root_dir .. "/src")
      return stat and stat.type == "directory"
    end

    local servers = {
      'matlab_ls', 'prismals', 'terraformls', 'ts_ls', 'kotlin_language_server',
      'eslint', 'bashls', 'cssls', 'html', 'jsonls', 'lemminx', 'marksman',
      'quick_lint_js', 'yamlls', 'remark_ls', 'dockerls',
      'docker_compose_language_service', 'taplo', 'arduino_language_server'
    }

    for _, server in ipairs(servers) do
      lspconfig[server].setup({
        capabilities = capabilities,
      })
    end

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          },
        },
      },
    })

    lspconfig.rust_analyzer.setup({
      capabilities = capabilities,
      on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      end,
      settings = {
        ['rust-analyzer'] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = 'clippy' },
          lens = { enable = true },
        },
      },
    })

    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = function(client)
        if client.server_capabilities.documentFormattingProvider then
          -- formatação opcional
        end
      end,
      before_init = function(_, config)
        local root_dir = config.root_dir or vim.fn.getcwd()
        local paths = {}
        if has_src_dir(root_dir) then
          table.insert(paths, root_dir .. "/src")
        end
        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          python = {
            analysis = {
              useLibraryCodeForTypes = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
              extraPaths = paths,
            },
          },
        })
      end,
    })

    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or 'rounded'
      return open_floating_preview(contents, syntax, opts, ...)
    end
  end,
}

