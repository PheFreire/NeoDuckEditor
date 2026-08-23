--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(LSP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<leader>gg', function() require('pato.core.c-hover').hover() end, { noremap = false, silent = true })
Km.set('n', '<leader>gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = false, silent = true })
Km.set('n', '<leader>gs', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', { noremap = false, silent = true })
Km.set('v', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', { noremap = false, silent = true })


Km.set('n', '<leader>er', function()
  local current_buf = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(current_buf)
  vim.cmd("silent bdelete!")
  vim.cmd("silent edit " .. vim.fn.fnameescape(filename)) -- Reabre arquivo, LSPs serão reiniciados
  vim.notify("🔁 Reabrindo buffer e reiniciando LSPs.")
end, { noremap = false, silent = true })


