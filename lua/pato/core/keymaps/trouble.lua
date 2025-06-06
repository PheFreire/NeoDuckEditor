-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Trouble)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', 'e', function()
  vim.diagnostic.open_float(nil, {
    focusable = true,
  })

  if vim.v.count == 2 then
    vim.cmd("wincmd w")
  end
end, { noremap = true, silent = true })
