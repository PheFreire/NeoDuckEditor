vim.g.mapleader = " "
Km = vim.keymap

local sysname = vim.loop.os_uname().sysname
local is_mac = sysname == "Darwin"

function Alt(key)
  if is_mac then
    return "<D-" .. key .. ">"
  else
    return "<A-" .. key .. ">"
  end
end

function Ctrl(key)
  if is_mac then
    return "<D-" .. key .. ">"
  else
    return "<A-" .. key .. ">"
  end
end

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Normal-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("n", "i", "<cmd>startinsert<CR><Right>", { noremap = false, silent = true })

Km.set("n", "k", "<Down>", { noremap = true, silent = true })
Km.set("n", "j", "<Up>", { noremap = true, silent = true })
Km.set("n", "<C-l>", "e", { noremap = true, silent = true })
Km.set("n", Alt("l"), "$", { noremap = true, silent = true })

Km.set("n", "<C-h>", "b", { noremap = true, silent = true })
Km.set("n", Alt("h"), "0", { noremap = true, silent = true })

Km.set("n", Alt("k"), "G", { noremap = true, silent = true })
Km.set("n", Alt("j"), "gg", { noremap = true, silent = true })

Km.set('n', 'l', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

Km.set('n', 'h', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Insert-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("i", Alt("Left"), "<C-o>0", { noremap = true, silent = true })
Km.set("i", Alt("Right"), "<C-o>$", { noremap = true, silent = true })

Km.set("i", Alt("k"), "<Down>", { noremap = true, silent = true })
Km.set("i", Alt("j"), "<Up>", { noremap = true, silent = true })
Km.set("i", Alt("h"), "<Left>", { noremap = true, silent = true })
Km.set("i", Alt("l"), "<Right>", { noremap = true, silent = true })

Km.set("i", Alt("K"), "<C-o>G", { noremap = true, silent = true })
Km.set("i", Alt("J"), "<C-o>gg", { noremap = true, silent = true })
Km.set("i", Alt("H"), "<C-o>:lua _G.ctrl_left()<CR>", { noremap = true, silent = true })
Km.set("i", Alt("L"), "<C-o>:lua _G.ctrl_right()<CR>", { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Visual-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("v", "k", "<Down>", { noremap = true, silent = true })
Km.set("v", "j", "<Up>", { noremap = true, silent = true })

Km.set("v", "<C-l>", "e", { noremap = true, silent = true })
Km.set("v", Alt("l"), "$", { noremap = true, silent = true })

Km.set("v", "<C-h>", "b", { noremap = true, silent = true })
Km.set("v", Alt("h"), "0", { noremap = true, silent = true })

Km.set("v", Alt("k"), "G", { noremap = true, silent = true })
Km.set("v", Alt("j"), "gg", { noremap = true, silent = true })

Km.set("v", Alt("k"), "G", { noremap = true, silent = true })
Km.set("v", Alt("j"), "gg", { noremap = true, silent = true })

Km.set('v', 'x', '"_d', { noremap = true, silent = true })

Km.set('v', 'l', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

Km.set('v', 'h', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

Km.set('v', '<Right>', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

Km.set('v', '<Left>', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Ctrl Movement Keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function _G.ctrl_right()
  local original_line = vim.fn.line('.')
  vim.cmd('normal! e')

  if vim.fn.line('.') ~= original_line then
    vim.cmd('normal! k$')
  end
  vim.fn.cursor(0, vim.fn.col('.') + 1)
end

function _G.ctrl_left()
  local original_line = vim.fn.line('.')
  vim.cmd('normal! b')

  if vim.fn.line('.') ~= original_line then
    vim.cmd('normal! j0')
  end
end

Km.set("i", "jk", "<ESC>", { noremap = false, silent = true }) -- exit insert mode with jk
Km.set('i', '<C-H>', '<C-w>', { noremap = true, silent = true }) -- Delete word with Crtl
Km.set('i', '<C-Right>', '<C-o>:lua _G.ctrl_right()<CR>', { noremap = true, silent = true })
Km.set('i', '<C-Left>', '<C-o>:lua _G.ctrl_left()<CR>', { noremap = true, silent = true })
Km.set('n', '<C-Right>', 'e', { noremap = true, silent = true })
Km.set('n', '<C-Left>', 'b', { noremap = true, silent = true })
Km.set('v', '<C-Left>', 'b', { noremap = true, silent = true })
Km.set('v', '<C-Right>', 'e', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General Buffer Keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("n", "<C-q>", ":q!<CR>", { noremap = false, silent = true }) -- quit without saving
Km.set("n", "<C-s>", ":w<CR>", { noremap = false, silent = true }) -- save
Km.set('n', '<leader>gb', ':e#<CR>', { silent = true }) -- Open last buffer
Km.set('i', '', '<C-o><cmd>w<CR>', { noremap = false, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Cell)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('i', '<A-Up>', "<Esc>0v$:m '<-2<CR>gv=gv<CR><Esc>i<Up>", { silent = true })
Km.set('i', '<A-Down>', "<Esc>$v$:m '>+1<CR>gv=gv<CR><Esc>i<Up>", { silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Window)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Mapeia Shift + k para rolar a tela para cima sem mover o cursor
Km.set('n', 'J', '<C-y>', { noremap = true, silent = true })

-- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor
Km.set('n', 'K', '<C-e>', { noremap = true, silent = true })

-- Mapeia Shift + k para rolar a tela para cima sem mover o cursor no modo Visual 
Km.set('v', 'J', '<C-y>', { noremap = true, silent = true })

-- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor no modo Visual
Km.set('v', 'K', '<C-e>', { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Break Text)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', 'm', ':set wrap!<CR>', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Undo/Reundo)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true, })
Km.set('i', '<A-z>', '<C-o><C-r>', { noremap = true, silent = true, })
Km.set('n', '<C-z>', 'u', { noremap = true, silent = true, })
Km.set('n', '<A-z>', '<C-r>', {noremap = true, silent = true, })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Clipboard)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('v', '<C-c>', '"+y', { noremap = true, }) -- copy to system clipboard
Km.set('v', '<C-x>', 'c', { noremap = true, silent = true, }) -- cut to system clipboard
Km.set("i", "<C-v>", "<C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR>", { noremap = true, silent = true }) -- cut from system clipboard

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Unammed Tabs)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '<leader>n', ':enew<CR>', { noremap = false, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Filter)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set('n', '//', ':noh<CR>', { noremap = true, silent = true })

