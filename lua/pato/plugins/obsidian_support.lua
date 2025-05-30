return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",
  
  config = function()
    require("obsidian").setup({
      workspaces = {
        {
          name = "Brain",
          path = "~/Documentos/dev/Brain",
        },
      },
      mappings = {
        ["<leader>gd"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
      },
      notes_subdir = "Notes",
      new_notes_location = "notes_subdir",

      ui = {
        checkboxes = {
          [" "] = { char = "☐", hl_group = "ObsidianTodo" },
          ["x"] = { char = "✔", hl_group = "ObsidianDone" },
          [">"] = { char = "→", hl_group = "ObsidianRightArrow" },
        },
      },

      attachments = {
        img_folder = "Assets/Images",
      },
    })
  end,
}



