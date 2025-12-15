return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local nvimtree = require("nvim-tree")
    
    local api = require('nvim-tree.api')
    vim.keymap.set('n', '<CR>', api.node.open.tab)
    vim.keymap.set('n', '<C-t>', ':lua CreateTerminalSession()<CR>')

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      view = {
        -- relativenumber = true,
        side = "right",
        adaptive_size = true,
        -- width = 30,
        preserve_window_proportions = true,
      },
      git = {
        ignore = false,
        enable = true,
      },
      -- Icons
      renderer = {
        root_folder_label = false,
        indent_markers = {
          enable = true,
        },
        icons = {
          show = {
            file = true,
            folder = true,
            git = true,
            folder_arrow = false
          },
          glyphs = {
            modified = "●",
            folder = {
              empty = "♙",
              empty_open = "♕",
              default = "♟",
              open = "♛",
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
        custom = { ".DS_Store", "__pycache__"  },
        dotfiles = false,
      },
    })
  end
}

