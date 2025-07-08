return {
  'projekt0n/github-nvim-theme',
  dependencies = 'nvim-tree/nvim-web-devicons',
  name = 'github-theme',
  config = function()
    require('github-theme').setup({
        darken = {
        sidebars = {
          enable = true, -- Habilitar o escurecimento das barras laterais
          list = { "NvimTree", "TelescopePrompt" }, -- Exemplo de sidebars que podem ser escurecidas
        },
      },
    })
  end,
}
