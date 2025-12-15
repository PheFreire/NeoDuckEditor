return {
  {
    "diegoulloao/xeno.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = false,
      contrast = 0.1,
    },
    config = function(_, opts)
      local xeno = require('xeno')
      xeno.config(opts)

      xeno.new_theme('dark-duck', {
        base = "#11100f",
        accent = "#FFCC33",
        variation = 0.0,
        contrast = 0.1,
        transparent = false,
      })
    end,
  },
}

