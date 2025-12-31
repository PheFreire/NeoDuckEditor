M = {}

function M.setRevealInFinderKeymaps(bufnr)
  local opts = {}
  if bufnr then opts.buffer = bufnr end

  local keymapOpts = vim.tbl_extend("force", opts, { noremap = true, silent = true })
  
  vim.keymap.set("n", "s", function()
  end, vim.tbl_extend("force", opts, { noremap = false }))
end

return M
