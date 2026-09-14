return {
  {
  "kyza0d/xeno.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = false,
    variation = 0.0,
    contrast = 0.0,
    -- Compensa a escala fixa de lightness da paleta nova (background_950 = 0.14
    -- por padrão, bem mais escuro que a versão antiga do plugin).
    lightness = 1.1,
  },
  config = function(_, opts)
    local xeno = require('xeno')
    xeno.config(opts)

    xeno.theme('dark-duck', {
      background = "#11100f",
      accent = "#FFCC33",
      transparent = false,
    })
  end,
  }
}

