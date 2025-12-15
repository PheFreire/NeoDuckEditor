local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup({ 
  { import = "pato.plugins" },
  { import = "pato.plugins.code-tool" },
  { import = "pato.plugins.file-support" },
  { import = "pato.plugins.home-page" },
  { import = "pato.plugins.language" },
  { import = "pato.plugins.optimization-tool" },
  { import = "pato.plugins.ui" },
  { import = "pato.plugins.utils" },
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
vim.cmd("silent !kitty @ set-spacing margin=0")

