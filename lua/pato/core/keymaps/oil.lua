Km.set("n", "<leader>f", function()
  local actions = require('oil.actions')
  local opts = require('pato.plugins.ui.oil').opts

  require("oil").open_float(nil, opts, function ()
    actions.preview.callback()
  end)
end, { desc = "Oil: abrir (float)", silent = true, noremap = true })


Km.set("n", "<leader>ee", function()
  local opts = require('pato.plugins.ui.oil').opts
  local actions = require('oil.actions')
  local cwd = vim.fn.getcwd()
  
  require("oil").open_float(cwd, opts, function ()
    actions.preview.callback()
  end)

end, { desc = "Oil: Open (float) on CWD Path", silent = true, noremap = true })

-- Km.set("n", "t", function()
--   local opts = require('pato.plugins.ui.oil').opts
--   local actions = require('oil.actions')

--   require("oil").open_float(nil, opts, function ()
--     actions.open_terminal.callback()
--   end)

-- end, { desc = "Oil: Open (float) on CWD Path", silent = true, noremap = true })
