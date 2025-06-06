--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Telescope)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<leader>fs', ':lua require"telescope.builtin".grep_string({ hidden = true })<CR>', { noremap = true, silent = true, })
Km.set("n", "<leader>ff", ':lua require"telescope.builtin".find_files({ hidden = true })<CR>', { noremap = true, silent = true,  })
Km.set("n", '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true, })
Km.set('n', '<leader>t', ':Telescope buffers<CR>', { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Theme Selection)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("n", "tt", function()
  local all = vim.fn.getcompletion("", "color")
  local filtered = vim.tbl_filter(function(name)
    return not vim.tbl_contains(Excluded, name)
  end, all)

  vim.ui.select(filtered, { prompt = "Pick your theme:" }, function(choice)
    if choice then
      vim.cmd.colorscheme(choice)
      vim.notify("Theme set to: " .. choice, vim.log.levels.INFO)
    end
  end)
end, { desc = "Pick theme (filtered)" })
