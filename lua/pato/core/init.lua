require("pato.core.highlights")
require("pato.core.options")
require("pato.core.aesthetics")
require("pato.core.keymaps")
require("pato.core.lsp-buffer")

local ks = require("pato.core.kitty_spacing")

vim.api.nvim_create_augroup("KittySpacing", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = "KittySpacing",
  callback = function() ks.zero() end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = "KittySpacing",
  callback = function() ks.restore() end,
})
