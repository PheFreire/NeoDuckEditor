--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(LSP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<leader>gg', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gs', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', { noremap = false, silent = true })
Km.set('v', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', { noremap = false, silent = true })


Km.set('n', '<leader>er', function()
  for _, client in pairs(vim.lsp.get_clients()) do
    client.stop()
  end
  vim.notify("🔁 Todos os LSPs foram encerrados. Eles serão reiniciados ao reabrir arquivos.")
end, { noremap = false, silent = true })

