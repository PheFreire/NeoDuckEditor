-- raiz de projeto + fonte do picker `Telescope projects` (antes vivia no alpha-nvim)
return {
  "ahmedkhalf/project.nvim",
  main = "project_nvim",
  event = "VeryLazy",
  opts = {
    detection_methods = { "pattern" },
    patterns = { ".git", "Makefile", "package.json" },
  },
}
