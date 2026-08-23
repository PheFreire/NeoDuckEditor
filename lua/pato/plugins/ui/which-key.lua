return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")

    wk.setup({
      preset  = "modern",
      delay   = 400,
      icons   = { rules = false },
      win     = { border = "rounded" },
    })

    wk.add({
      { "<leader>d",  group = "Debug" },
      { "<leader>dc", desc = "Start / Continue" },
      { "<leader>ds", desc = "Step Over" },
      { "<leader>di", desc = "Step Into" },
      { "<leader>do", desc = "Step Out" },
      { "<leader>dl", desc = "Run Last" },
      { "<leader>dR", desc = "Restart" },
      { "<leader>dq", desc = "Terminate" },
      { "<leader>db", desc = "Toggle Breakpoint" },
      { "<leader>dB", desc = "Conditional Breakpoint" },
      { "<leader>dL", desc = "Logpoint" },
      { "<leader>dC", desc = "Clear All Breakpoints" },
      { "<leader>du", desc = "Toggle UI" },
      { "<leader>de", desc = "Eval Expression / Selection" },
      { "<leader>dr", desc = "Open REPL" },
    })
  end,
}
