return {
  {
  "kyza0d/xeno.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    transparent = false,
    variation = 0.0,
    contrast = 0.0,
    -- Compensa a escala fixa de lightness da paleta (background_950 = 0.14
    -- por padrão); 0.3 reproduz o hex literal de `background` abaixo (#11100f).
    lightness = 0.3,
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

