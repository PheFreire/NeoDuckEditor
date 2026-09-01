return {
  url = "https://codeberg.org/andyg/leap.nvim",
  name = 'leap',
  -- só é usado via <leader>sw (core/keymaps/leap.lua), que faz require('leap')
  lazy = true,
  config = function()
    local leap = require('leap')
    leap.opts.vim_opts['go.ignorecase'] = false
  end,
}
