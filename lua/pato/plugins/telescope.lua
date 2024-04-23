return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local transform_mod = require("telescope.actions.mt").transform_mod
  
      local trouble = require("trouble")
      local trouble_telescope = require("trouble.providers.telescope")
  
      -- or create your custom action
      local custom_actions = transform_mod({
        open_trouble_qflist = function(prompt_bufnr)
          trouble.toggle("quickfix")
        end,
      })

      telescope.setup({
        defaults = {
          path_display = { "smart" },
          mappings = {
            i = {
              ["<C-k>"] = actions.move_selection_previous, -- move to prev result
              ["<C-j>"] = actions.move_selection_next, -- move to next result
              ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
              ["<C-t>"] = trouble_telescope.smart_open_with_trouble, 
          },
          },
        },
      })
  
      telescope.load_extension("fzf")
  
      -- keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
      -- keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
      -- keymap.set('n', '<leader>fb', ':lua require"telescope.builtin".buffers()', {})
      -- keymap.set('n', '<leader>fh', ":lua require('telescope.builtin').help_tags", {})
      -- keymap.set('n', '<leader>ff', ':lua require"telescope.builtin".current_buffer_fuzzy_find({ hidden = true })<CR>', {})
      -- keymap.set('n', '<leader>fo', ":lua require('telescope.builtin').lsp_document_symbols", {})
      -- keymap.set('n', '<leader>fi', ":lua require('telescope.builtin').lsp_incoming_calls", {})
      -- keymap.set('n', '<leader>fm', ":lua function() require('telescope.builtin').treesitter({default_text=":method:"}) end)

    end,
  }



