-- raiz de projeto + fonte do picker `Telescope projects` (antes vivia no alpha-nvim)
return {
  "ahmedkhalf/project.nvim",
  main = "project_nvim",
  -- Precisa carregar antes do primeiro BufEnter para detectar a raiz do
  -- projeto já na abertura do Neovim; VeryLazy dispara tarde demais para isso.
  lazy = false,
  opts = {
    detection_methods = { "pattern" },
    patterns = { ".git", "Makefile", "package.json" },
    -- documentação pessoal (:doc/:docs/:docd) não deve trocar o cwd do projeto atual
    exclude_dirs = {
      vim.fn.stdpath("config") .. "/doc",
      vim.fn.stdpath("config") .. "/doc/*",
    },
  },
}
