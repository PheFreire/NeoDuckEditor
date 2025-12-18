-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Trouble)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', 'e', function()
  vim.diagnostic.open_float(nil, {
    focusable = true,
  })

  if vim.v.count == 2 then
    vim.cmd("wincmd w")
  end
end, { noremap = true, silent = true })

Km.set('n', 'ee', function()
  require("telescope.builtin").diagnostics({
    bufnr = nil,
    severity = vim.diagnostic.severity.ERROR,
  })
end, { silent = true, desc = "Workspace errors only" })
