vim.g.mapleader = " "
vim.keymap = vim.keymap

local sysname = vim.loop.os_uname().sysname
local is_mac = sysname == "Darwin"
Km = vim.keymap

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Normal-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

local M = {}

function M.setDefaultNavigationKeymaps(bufnr)
  local opts = {}
  if bufnr then opts.buffer = bufnr end

  local keymapOpts = vim.tbl_extend("force", opts, { noremap = true, silent = true })

  vim.keymap.set("n", "i", "<cmd>startinsert<CR><Right>", keymapOpts)

  vim.keymap.set("n", "k", "<Down>", keymapOpts)
  vim.keymap.set("n", "j", "<Up>", keymapOpts)
  vim.keymap.set("n", "<C-l>", "e", keymapOpts)
  vim.keymap.set("n", "<A-l>", "$", keymapOpts)

  vim.keymap.set("n", "<C-h>", "b", keymapOpts)
  vim.keymap.set("n", "<A-h>", "0", keymapOpts)

  vim.keymap.set("n", "<A-k>", "G", keymapOpts)
  vim.keymap.set("n", "<A-j>", "gg", keymapOpts)

  vim.keymap.set('n', 'l', function ()
      local col = vim.fn.col('.')
      local line = vim.fn.getline('.')
      if col >= #line then
          vim.cmd('silent normal! j0')
      else
          vim.cmd('silent normal! l')
      end
  end, keymapOpts)

  vim.keymap.set('n', 'h', function ()
      local col = vim.fn.col('.')
      if col == 1 then
          vim.cmd('silent normal! k$')
      else
          vim.cmd('silent normal! h')
      end
  end,  keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Insert-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set("i", "<A-Left>", "<C-o>0", keymapOpts)
  vim.keymap.set("i", "<A-Right>", "<C-o>$", keymapOpts)

  vim.keymap.set("i", "<A-k>", "<Down>", keymapOpts)
  vim.keymap.set("i", "<A-j>", "<Up>", keymapOpts)
  vim.keymap.set("i", "<A-h>", "<Left>", keymapOpts)
  vim.keymap.set("i", "<A-l>", "<Right>", keymapOpts)

  vim.keymap.set("i", "<A-K>", "<C-o>G", keymapOpts)
  vim.keymap.set("i", "<A-J>", "<C-o>gg", keymapOpts)
  vim.keymap.set("i", "<A-H>", "<C-o>:lua _G.ctrl_left()<CR>", keymapOpts)
  vim.keymap.set("i", "<A-L>", "<C-o>:lua _G.ctrl_right()<CR>", keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Visual-Mode Movement keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set("v", "k", "<Down>", keymapOpts)
  vim.keymap.set("v", "j", "<Up>", keymapOpts)

  vim.keymap.set("v", "<C-l>", "e", keymapOpts)
  vim.keymap.set("v", "<A-l>", "$", keymapOpts)

  vim.keymap.set("v", "<C-h>", "b", keymapOpts)
  vim.keymap.set("v", "<A-h>", "0", keymapOpts)

  vim.keymap.set("v", "<A-k>", "G", keymapOpts)
  vim.keymap.set("v", "<A-j>", "gg", keymapOpts)

  vim.keymap.set("v", "<A-k>", "G", keymapOpts)
  vim.keymap.set("v", "<A-j>", "gg", keymapOpts)

  vim.keymap.set('v', 'x', '"_d', keymapOpts)

  vim.keymap.set('v', 'l', function ()
      local col = vim.fn.col('.')
      local line = vim.fn.getline('.')
      if col >= #line then
          vim.cmd('silent normal! j0')
      else
          vim.cmd('silent normal! l')
      end
  end, keymapOpts)

  vim.keymap.set('v', 'h', function ()
      local col = vim.fn.col('.')
      if col == 1 then
          vim.cmd('silent normal! k$')
      else
          vim.cmd('silent normal! h')
      end
  end,  keymapOpts)

  vim.keymap.set('v', '<Right>', function ()
      local col = vim.fn.col('.')
      local line = vim.fn.getline('.')
      if col >= #line then
          vim.cmd('silent normal! j0')
      else
          vim.cmd('silent normal! l')
      end
  end, keymapOpts)

  vim.keymap.set('v', '<Left>', function ()
      local col = vim.fn.col('.')
      if col == 1 then
          vim.cmd('silent normal! k$')
      else
          vim.cmd('silent normal! h')
      end
  end, keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Ctrl Movement Keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  function _G.ctrl_right()
    local original_line = vim.fn.line('.')
    vim.cmd('silent normal! e')

    if vim.fn.line('.') ~= original_line then
      vim.cmd('silent normal! k$')
    end
    vim.fn.cursor(0, vim.fn.col('.') + 1)
  end

  function _G.ctrl_left()
    local original_line = vim.fn.line('.')
    vim.cmd('silent normal! b')

    if vim.fn.line('.') ~= original_line then
      vim.cmd('silent normal! j0')
    end
  end

  vim.keymap.set("i", "jk", "<ESC>", keymapOpts) -- exit insert mode with jk
  vim.keymap.set('i', '<C-H>', '<C-w>', keymapOpts) -- Delete word with Crtl
  vim.keymap.set('i', '<C-Right>', '<C-o>:lua _G.ctrl_right()<CR>', keymapOpts)
  vim.keymap.set('i', '<C-Left>', '<C-o>:lua _G.ctrl_left()<CR>', keymapOpts)
  vim.keymap.set('n', '<C-Right>', 'e', keymapOpts)
  vim.keymap.set('n', '<C-Left>', 'b', keymapOpts)
  vim.keymap.set('v', '<C-Left>', 'b', keymapOpts)
  vim.keymap.set('v', '<C-Right>', 'e', keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General Buffer Keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set("n", "<C-q>", "<cmd>q!<CR>", keymapOpts) -- quit without saving
  vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", keymapOpts) -- save
  vim.keymap.set('n', '<leader>gb', '<cmd>e#<CR>', keymapOpts) -- Open last buffer
  vim.keymap.set('i', '', '<C-o><cmd>w<CR>', keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Cell)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set('i', '<A-Up>', "<Esc>0v$:m '<-2<CR>gv=gv<CR><Esc>i<Up>", keymapOpts)
  vim.keymap.set('i', '<A-Down>', "<Esc>$v$:m '>+1<CR>gv=gv<CR><Esc>i<Up>", keymapOpts)

  -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Window)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  -- Mapeia Shift + k para rolar a tela para cima sem mover o cursor
  vim.keymap.set('n', 'J', '2<C-y>', keymapOpts)

  -- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor
  vim.keymap.set('n', 'K', '2<C-e>', keymapOpts)

  -- Mapeia Shift + k para rolar a tela para cima sem mover o cursor no modo Visual 
  vim.keymap.set('v', 'J', '2<C-y>', keymapOpts)

  -- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor no modo Visual
  vim.keymap.set('v', 'K', '2<C-e>', keymapOpts)

  -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Break Text)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set('n', 'm', '<cmd>set wrap!<CR>', keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Undo/Reundo)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  -- vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true, })

  vim.keymap.set('i', '<C-z>', function ()
    local ut = vim.fn.undotree()
    if (ut.seq_last or 0) > 0 and (ut.seq_cur or 0) > 0 then
      vim.cmd('silent normal! u')
    end
  end, keymapOpts)
  vim.keymap.set('i', '<A-z>', '<C-o><C-r>', keymapOpts)
  vim.keymap.set('n', '<C-z>', 'u', keymapOpts)
  vim.keymap.set('n', '<A-z>', '<C-r>', keymapOpts)

  --=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Clipboard)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set('v', '<C-c>', '"+y', keymapOpts) -- copy to system clipboard
  vim.keymap.set('v', '<C-x>', 'c', keymapOpts) -- cut to system clipboard
  vim.keymap.set("i", "<C-v>", "<C-o>:set paste<CR><C-r>+<C-o>:set nopaste<CR>", keymapOpts)

  -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Unammed Tabs)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set('n', '<leader>n', '<cmd>enew<CR>', keymapOpts)

  -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Filter)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

  vim.keymap.set('n', '//', '<cmd>noh<CR>', keymapOpts)
end

M.setDefaultNavigationKeymaps()

return M
