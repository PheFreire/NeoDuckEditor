return {
  'projekt0n/github-nvim-theme',
  name = 'github-theme',
  lazy = false, -- make sure we load this during startup if it is your main colorscheme
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require('github-theme').setup({
        darken = {
        sidebars = {
          enable = true, -- Habilitar o escurecimento das barras laterais
          list = { "NvimTree", "TelescopePrompt" }, -- Exemplo de sidebars que podem ser escurecidas
        },
      },
    })
    -- github_dark_dimmed | github_dark |  dark_default
      vim.cmd('colorscheme github_dark')

  end,
  -- vim.cmd('highlight Normal guibg=#292c2e')
  -- vim.cmd('highlight Normal guibg=#2a2d30')
  -- vim.cmd('highlight Normal guibg=#26292d')
}
