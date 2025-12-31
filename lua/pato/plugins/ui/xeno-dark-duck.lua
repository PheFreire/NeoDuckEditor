return {
  {
  "kyza0d/xeno.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = false,
    variation = 0.0,
    contrast = 0.0,
  },
  config = function(_, opts)
    local xeno = require('xeno')
    xeno.config(opts)

    xeno.new_theme('dark-duck', {
      base = "#11100f",
      accent = "#FFCC33",
      transparent = false,
    })
  end,
  }
}

