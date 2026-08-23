return {
  "LunarVim/bigfile.nvim",
  event = "BufReadPre",
  opts = {
    filesize = 2, -- MB. Arquivos maiores que isso serão otimizados
    features = {
      "lsp",
      "treesitter",
      "syntax",
      "illuminate",
      "indent_blankline",
      "matchparen",
      "vimopts",
    }
  }
}

