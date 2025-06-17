return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "j-hui/fidget.nvim",
    { "WhoIsSethDaniel/mason-tool-installer.nvim" }
  },
  config = function()
    require("fidget")
    
    require("mason").setup()
    local ensure_installed = {
      'terraformls', 'ts_ls', 'eslint', 'bashls',
      'cssls', 'html', 'lua_ls', 'jsonls', 'lemminx', 'marksman', 'quick_lint_js',
      'yamlls', 'remark_ls', 'dockerls', 'prismals',
      'taplo', "pyright", "rust_analyzer",
    }

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace = capabilities.workspace or {}
    capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles or {}
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    mason_lspconfig.setup({
      ensure_installed = ensure_installed,
      automatic_installation = false,
      auto_update = true,
      run_on_start = true,
    })

    require("mason-tool-installer").setup({
      ensure_installed = ensure_installed,
      auto_update = true,
      run_on_start = true,
    })

    -- Setup manual do pyright
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        for _, c in pairs(vim.lsp.get_clients()) do
          if c.name == "pyright" and c.id ~= client.id then
            client.stop()
            return
          end
        end
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            typeCheckingMode = "basic",
            useLibraryCodeForTypes = true,
            extraPaths = { "src" },
            ignore = { "build", "dist", "**/__pycache__/**" },
          },
        },
      },
    })

    -- Setup do Rust (opcional)
    lspconfig.rust_analyzer.setup({
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
          lens = { enable = true },
        },
      },
    })

    vim.api.nvim_create_user_command("MasonSyncLSPs", function()
      local mason_registry = require("mason-registry")
      local desired_lsps = ensure_installed

      local installed = {}
      for _, pkg in ipairs(mason_registry.get_installed_packages()) do
        table.insert(installed, pkg.name)
      end

      local to_install = {}
      local to_uninstall = {}
      
      local desired_set = {}
      for _, name in ipairs(desired_lsps) do
        desired_set[name] = true
        if not mason_registry.is_installed(name) then
          table.insert(to_install, name)
        end
      end
      
      for _, name in ipairs(installed) do
        if not desired_set[name] then
          table.insert(to_uninstall, name)
        end
      end
      
      for _, name in ipairs(to_install) do
        if mason_registry.has_package(name) then
          local ok, pkg = pcall(mason_registry.get_package, name)
          if ok then
            vim.notify("🔧 Installing LSP: " .. name, vim.log.levels.INFO)
            pkg:install()
          end
        else
          vim.notify("⚠️ Mason: Package not found: " .. name, vim.log.levels.ERROR)
        end
      end
      
      for _, name in ipairs(to_uninstall) do
        local ok, pkg = pcall(mason_registry.get_package, name)
        if ok then
          vim.notify("🧹 Uninstalling unused LSP: " .. name, vim.log.levels.WARN)
          pkg:uninstall()
        end
      end
      
      if #to_install == 0 and #to_uninstall == 0 then
        vim.notify("✅ All desired LSPs already installed.", vim.log.levels.INFO)
      end
    end, { desc = "Sync LSPs installed via Mason with desired list" })
    
    local open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      return open_floating_preview(contents, syntax, opts, ...)
    end
  end,
}
