return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
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
        defaults = { path_display = { "smart" } } 
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
    -- local telescope = require("telescope")

    local telescopeConfig = require("telescope.config")

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

    -- I want to search in hidden/dot files.
    table.insert(vimgrep_arguments, "--hidden")
    
    -- I don't want to search in the `.git` directory.
    table.insert(vimgrep_arguments, "--glob")
    table.insert(vimgrep_arguments, "!**/.git/*")
    table.insert(vimgrep_arguments, "!**/../*")

  telescope.setup({
	  defaults = {
		  -- `hidden = true` is not supported in text grep commands.
		  vimgrep_arguments = vimgrep_arguments,
	  },
	  pickers = {
		  find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			  find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		  },
	  },
  })
    end,
  }



