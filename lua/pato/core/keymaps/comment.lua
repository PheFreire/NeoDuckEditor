-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Comment)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<C-_>', '<cmd>Comment<CR>', { noremap = true, silent = true })
Km.set('v', '<C-_>', ':Comment<CR>', { noremap = true, silent = true })
Km.set('i', '<C-_>', '<C-o><cmd>Comment<CR>', { noremap = true, silent = true })
