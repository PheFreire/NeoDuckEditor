-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Visual Multi)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
local M = {}
function M.setDefaultVisualMultiKeymaps(bufnr)
  local opts = {}
  if bufnr then opts.buffer = bufnr end

  local keymapOpts = vim.tbl_extend("force", opts, { noremap = true, silent = true })

  vim.keymap.set('n', '<C-c>', '"+<Plug>(VM-Yank)<Plug>(VM-Exit)', keymapOpts)
  vim.keymap.set('i', '<A-s>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)s<Plug>(VM-Exit)', keymapOpts)
  vim.keymap.set('i', '<A-d>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)P<Plug>(VM-Exit)', keymapOpts)
end

M.setDefaultVisualMultiKeymaps()

return M
