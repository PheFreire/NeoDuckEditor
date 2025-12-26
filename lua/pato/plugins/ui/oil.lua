return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    default_file_explorer = true,
    use_default_keymaps = true,
    view_options = {
      show_hidden = true,
    }
  },
  config = function(_, opts)
    require("oil").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function(ev)
        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "Oil: fechar" })
        vim.keymap.set("n", "q", "<cmd>close<CR>",   { buffer = ev.buf, silent = true, desc = "Oil: fechar" })
        vim.keymap.set({ "n", "i" }, "<C-s>", function()
          vim.cmd("write")
        end, { buffer = ev.buf, silent = true, desc = "Oil: aplicar mudanças" })
      end,
    })

  end,
}

