return {
  "goolord/alpha-nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Custom dashboard button
    dashboard.section.buttons.val = {
      dashboard.button("p", "  Recent projects", "<cmd>Telescope projects<CR>"),
      dashboard.button("f", "󰈞  Find file", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
    }

    dashboard.section.footer.val = "Welcome back! 🚀"
    dashboard.section.footer.opts.hl = "Comment"

    alpha.setup(dashboard.opts)
  end,
}

