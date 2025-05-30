return {
  "nvim-pack/nvim-spectre",
  config = function()
    require("spectre").setup()
    vim.keymap.set("n", "<leader>S", function()
      require("spectre").toggle()
    end, { desc = "Toggle Spectre" })
  end,
}
