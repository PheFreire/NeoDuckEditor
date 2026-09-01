return {
  "ellisonleao/dotenv.nvim",
  event = "VeryLazy",
  config = function()
    require("dotenv").setup()
  end,
}
