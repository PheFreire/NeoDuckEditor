return {
  url = "https://codeberg.org/andyg/leap.nvim",
  name = 'leap',
  config = function()
    local leap = require('leap')
    leap.opts.case_sensitive = true
  end,
}
