return {
  -- Bealtiful docs:
  -- https://github.com/stevearc/oil.nvim
  -- https://github.com/stevearc/oil.nvim/blob/master/doc/oil.txt
  -- https://github.com/stevearc/oil.nvim/blob/master/doc/api.md
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    default_file_explorer = true,
    skip_confirm_for_simple_edits = false,
    columns = {
      "icon",
    },
    use_default_keymaps = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      preview_split = "right",
    },
    delete_to_trash = true,
  },
  config = function(_, opts)
    local oil = require("oil")
    oil.setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function(ev)
        local keymapsOpts = { buffer = ev.buf, silent = true }

        vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>write<cr>", keymapsOpts)
        vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", keymapsOpts)
        vim.keymap.set("n", "q", "<cmd>close<CR>", keymapsOpts)

        vim.keymap.set("n", "o", function()
          local dirPath = oil.get_current_dir(ev.buf)
          local fileName = oil.get_cursor_entry(ev.buf).name
          local command = string.format("silent! !Open %s/%s", dirPath, fileName)

          vim.cmd(command)
        end, keymapsOpts)

        local defaultCoreKeymaps = require("pato.core.keymaps.core")
        defaultCoreKeymaps.setDefaultNavigationKeymaps(ev.buf)

        local defaultVisualKeymaps = require("pato.core.keymaps.visual-multi")
        defaultVisualKeymaps.setDefaultVisualMultiKeymaps(ev.buf)

        local defaultRevealInFinderKeymaps = require("pato.core.keymaps.revel-in-finder")
        defaultRevealInFinderKeymaps.setRevealInFinderKeymaps(ev.buf)

        vim.keymap.set("n", "v", "V", keymapsOpts)
        vim.keymap.set("n", "<A-v>", "V", keymapsOpts)
      end
    })
  end,
}

