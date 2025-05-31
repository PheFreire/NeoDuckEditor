return {
  "TimUntersberger/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "lewis6991/gitsigns.nvim",
  },
  config = function()
    -- Gitsigns
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gb", function() gs.blame_line({ full = true }) end, "Git Blame")
      end
    })

    -- Diffview
    require("diffview").setup()

    -- Neogit
    require("neogit").setup({
      integrations = { diffview = true },
      signs = {
        section = { "▸", "▾" },
        item = { "●", "○" },
      },
      mappings = {
        commit_editor = {
          ["j"] = "PrevMessage",
          ["k"] = "NextMessage",
        },
        rebase_editor = {
          ["j"] = "MoveUp",
          ["k"] = "MoveDown",
          ["J"] = "OpenOrScrollUp",
          ["K"] = "OpenOrScrollDown",
        },
        finder = {
          ["k"] = "Next",
          ["j"] = "Previous",
        },
        status = {
          ["j"] = "MoveUp",
          ["k"] = "MoveDown",
          ["J"] = "OpenOrScrollUp",
          ["K"] = "OpenOrScrollDown",
          ["<c-j>"] = "PeekUp",
          ["<c-k>"] = "PeekDown",
        },
        log_view = {}
      },
    })

    -- Atalho para abrir o Neogit
    vim.keymap.set("n", "g", ":Neogit<CR>", { desc = "Abrir painel Git (Neogit)" })
  end,
}

