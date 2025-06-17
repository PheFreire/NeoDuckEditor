return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "nightfly",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },

      sections = {
        lualine_a = { { "mode", icon = "" } },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            diff_color = {
              added = { fg = "#A3BE8C" },
              modified = { fg = "#EBCB8B" },
              removed = { fg = "#BF616A" },
            },
            colored = true,
          },
          {
            "diagnostics",
            sources = { "nvim_lsp" },
            sections = { "error", "warn", "info", "hint" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            colored = true,
            update_in_insert = false,
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
            file_status = true,
            newfile_status = true,
            symbols = {
              modified = "[+]",
              readonly = "[-]",
              unnamed = "[No Name]",
              newfile = "[New]",
            },
          },
        },
        lualine_x = {
          { "filetype", icon_only = true, separator = "" },
          "encoding",
          "fileformat",
        },
        lualine_y = { "progress" },
        lualine_z = { { "location", icon = "" } },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },

      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}

