Km.set("n", "<leader>f", function()
  local opts = require("pato.plugins.ui.oil").opts
  require("oil").open(nil, opts)
end, { desc = "Oil: abrir (float)", silent = true, noremap = true })

Km.set("n", "<leader>ee", function()
  local opts = require("pato.plugins.ui.oil").opts
  local cwd = vim.fn.getcwd()
  vim.cmd("tabnew")

  require("oil").open(cwd, opts)
end, { desc = "Oil: Open (float) on CWD Path", silent = true, noremap = true })

Km.set("n", "p", function()
  local opts = require("pato.plugins.ui.oil").opts
  require("oil").open_preview(opts)
end, { desc = "Oil: Open Preview", silent = true, noremap = true })
