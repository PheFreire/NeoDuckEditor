return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "williamboman/mason.nvim", "j-hui/fidget.nvim", { "WhoIsSethDaniel/mason-tool-installer.nvim" } },
  config = function()
    require("fidget")
    local ensure_installed = {
      'prisma-language-server', 'terraformls', 'ts_ls', 'kotlin_language_server','eslint', 'bashls',
      'cssls', 'html', 'lua_ls', 'jsonls', 'lemminx', 'marksman', 'quick_lint_js',
      'yamlls', 'remark_ls', 'dockerls', 'docker_compose_language_service',
      'taplo',
    }
    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
      automatic_installation = false,
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        'black', 'flake8', 'isort', 'mypy', 'pylint',
      },
      run_on_start = true,
      auto_update = true,
      start_delay = 3000,
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
