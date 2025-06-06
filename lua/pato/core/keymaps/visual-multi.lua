-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Visual Multi)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<C-c>', '"+<Plug>(VM-Yank)<Plug>(VM-Exit)', { noremap = false, silent = true })
Km.set('i', '<A-s>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)s<Plug>(VM-Exit)', { noremap = false, silent = true })
Km.set('i', '<A-d>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)P<Plug>(VM-Exit)', { noremap = false, silent = true })
