return {
  url = "https://codeberg.org/andyg/leap.nvim",
  name = 'leap',
  config = function()
    local leap = require('leap')
    leap.opts.vim_opts['go.ignorecase'] = false
  end,
}
