return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace = capabilities.workspace or {}
    capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles or {}
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

    mason_lspconfig.setup({
      ensure_installed = { "pyright", "rust_analyzer" },
      automatic_installation = false,
    })

    -- Setup manual do pyright
    lspconfig.pyright.setup({
      capabilities = capabilities,
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
  end,
}

