return {
  "nvim-treesitter/nvim-treesitter",
  lazy = true,
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  opts = {
    -- Lista de linguagens obrigatórias para instalar
    ensure_installed = {
      "lua",
      "javascript",
      "typescript",
      "tsx",
      "css",
      "json",
    },

    -- Instala linguagens automaticamente ao entrar em novos buffers
    auto_install = true,

    -- Suporte a indentação baseada na árvore sintática
    indent = {
      enable = true,
    },

    -- Syntax Highlighting + filtro para evitar erro de janelas inválidas
    highlight = {
      enable = true,
      disable = function(_, buf)
        local bt = vim.bo[buf].buftype
        return bt == "nofile" or bt == "prompt" or bt == "nowrite"
      end,
    },
  },
  config = function(_, opts)
    local configs = require("nvim-treesitter.configs")
    configs.setup(opts)
  end,
}

