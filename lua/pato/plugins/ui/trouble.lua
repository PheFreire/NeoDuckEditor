return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  config = function()
    require("trouble").setup {
      mode = "workspace_diagnostics",
      auto_open = false,
      auto_close = true,
    }
  end
}
