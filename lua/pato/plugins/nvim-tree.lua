return {
  "nvim-tree/nvim-tree.lua",
  requires = {
    'nvim-tree/nvim-web-devicons', -- Recomendado para ícones de desenvolvedor
  },
  priority = 1000,
  config = function()
    require 'nvim-web-devicons'.setup()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 35,
        -- relativenumber = true,
        side = "right",
      },
      git = {
        ignore = false,
        enable = true,
      },
      -- Icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            modified = "●",
            folder = {
              empty = "📁",
              empty_open = "📂",
              default = "📁",
              open = "📂",
              arrow_open = "▾",
              -- arrow_open = "↓",
              arrow_closed = "▸",
              -- arrow_closed = "→",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "U",
              renamed = "➜",
              untracked = "★",
              deleted = "D",
              ignored = "◌",
            },
          },
        },
      },

      -- disable window_picker to enable window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
        dotfiles = false,
      },
    })
  end
}

