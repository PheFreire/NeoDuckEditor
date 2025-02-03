-- Set leader key to space
vim.g.mapleader = " "
local keymap = vim.keymap

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "i", "<cmd>startinsert<CR><Right>", { noremap = false, silent = true })

keymap.set("n", "k", "<Down>", { noremap = true, silent = true })
keymap.set("n", "j", "<Up>", { noremap = true, silent = true })
keymap.set("n", "<C-l>", "e", { noremap = true, silent = true })
keymap.set("n", "<A-l>", "$", { noremap = true, silent = true })

keymap.set("n", "<C-h>", "b", { noremap = true, silent = true })
keymap.set("n", "<A-h>", "0", { noremap = true, silent = true })

keymap.set("i", "<A-Left>", "<C-o>0", { noremap = true, silent = true })
keymap.set("i", "<A-Right>", "<C-o>$", { noremap = true, silent = true })

keymap.set("n", "<A-k>", "G", { noremap = true, silent = true })
keymap.set("n", "<A-j>", "gg", { noremap = true, silent = true })
keymap.set("n", "<C-q>", ":q!<CR>", { noremap = false, silent = true }) -- quit without saving
keymap.set("n", "<C-s>", ":w<CR>", { noremap = false, silent = true }) -- save
keymap.set('n', '<leader>gb', ':e#<CR>', { silent = true }) -- Open last buffer

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps visual mode)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("i", "<A-k>", "<Down>", { noremap = true, silent = true })
keymap.set("i", "<A-j>", "<Up>", { noremap = true, silent = true })
keymap.set("i", "<A-h>", "<Left>", { noremap = true, silent = true })
keymap.set("i", "<A-l>", "<Right>", { noremap = true, silent = true })

keymap.set("i", "<A-K>", "<C-o>G", { noremap = true, silent = true })
keymap.set("i", "<A-J>", "<C-o>gg", { noremap = true, silent = true })
keymap.set("i", "<A-H>", "<C-o>:lua _G.ctrl_left()<CR>", { noremap = true, silent = true })
keymap.set("i", "<A-L>", "<C-o>:lua _G.ctrl_right()<CR>", { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps visual-mode)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("v", "k", "<Down>", { noremap = true, silent = true })
keymap.set("v", "j", "<Up>", { noremap = true, silent = true })

keymap.set("v", "<C-l>", "e", { noremap = true, silent = true })
keymap.set("v", "<A-l>", "$", { noremap = true, silent = true })

keymap.set("v", "<C-h>", "b", { noremap = true, silent = true })
keymap.set("v", "<A-h>", "0", { noremap = true, silent = true })

keymap.set("v", "<A-k>", "G", { noremap = true, silent = true })
keymap.set("v", "<A-j>", "gg", { noremap = true, silent = true })

keymap.set("v", "<A-k>", "G", { noremap = true, silent = true })
keymap.set("v", "<A-j>", "gg", { noremap = true, silent = true })

keymap.set('v', 'x', '"_d', { noremap = true, silent = true })

keymap.set('n', 'l', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

keymap.set('n', 'h', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

keymap.set('v', 'l', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

keymap.set('v', 'h', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

keymap.set('v', '<Right>', function ()
    local col = vim.fn.col('.')
    local line = vim.fn.getline('.')
    if col >= #line then
        vim.cmd('normal! j0')
    else
        vim.cmd('normal! l')
    end
end, { noremap = true, silent = true })

keymap.set('v', '<Left>', function ()
    local col = vim.fn.col('.')
    if col == 1 then
        vim.cmd('normal! k$')
    else
        vim.cmd('normal! h')
    end
end,  { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps editor-model)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


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

keymap.set("i", "jk", "<ESC>", { noremap = false, silent = true }) -- exit insert mode with jk dsada
keymap.set('i', '<C-H>', '<C-w>', { noremap = true, silent = true }) -- Delete word with Crtl
keymap.set('i', '<C-Right>', '<C-o>:lua _G.ctrl_right()<CR>', { noremap = true, silent = true })
keymap.set('i', '<C-Left>', '<C-o>:lua _G.ctrl_left()<CR>', { noremap = true, silent = true })
keymap.set('n', '<C-Right>', 'e', { noremap = true, silent = true })
keymap.set('n', '<C-Left>', 'b', { noremap = true, silent = true })
keymap.set('v', '<C-Left>', 'b', { noremap = true, silent = true })
keymap.set('v', '<C-Right>', 'e', { noremap = true, silent = true })
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Split window management)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>s", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>ss", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
keymap.set("n", "<leader>sj", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>sk", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>5") -- make split windows width bigger 
keymap.set("n", "<leader>sh", "<C-w><5") -- make split windows width smaller

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Tab Management)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open a new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close a tab
keymap.set("n", "<leader>l", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>h", ":tabp<CR>") -- previous tab

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Nvim-tree)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>") -- toggle file explorer
keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>") -- find file in file explorer
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>:LspRestart<CR><cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(LSP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>gg', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = false, silent = true })
keymap.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false, silent = true })
keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', { noremap = false, silent = true })
keymap.set('n', '<leader>gs', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', { noremap = false, silent = true })
keymap.set('v', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>', { noremap = false, silent = true })
-- keymap.set('i', '<C-A-a>', '<C-e>') -- Close LSP sugetion
keymap.set('n', 'g', function ()
    for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then  -- Se a janela for relativa (flutuante)
            vim.api.nvim_win_close(win, true)  -- Fecha a janela
        end
    end
end, { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Clipboard)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('v', '<C-c>', '"+y', { noremap = true, }) -- copy to system clipboard
keymap.set('i', '<C-v>', '<Left><C-o>p', { noremap = true, }) -- paste system clipboard data
keymap.set('v', '<C-x>', 'c', { noremap = true, silent = true, })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Undo/Reundo)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Mapeamento de teclas para <C-z> no modo de inserção
keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, silent = true, })
keymap.set('i', '<A-z>', '<C-o><C-r>', { noremap = true, silent = true, })
keymap.set('n', '<C-z>', 'u', { noremap = true, silent = true, })
keymap.set('n', '<A-z>', '<C-r>', {noremap = true, silent = true, })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Telescope)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>fs', ':lua require"telescope.builtin".grep_string({ hidden = true })<CR>', { noremap = true, silent = true, })
keymap.set("n", "<leader>ff", ':lua require"telescope.builtin".find_files({ hidden = true })<CR>', { noremap = true, silent = true,  })
keymap.set("n", '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true, })
keymap.set('n', '<leader>t', ':Telescope buffers<CR>', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(File CRUD)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- keymap.set('n', '<C-d>', ":call delete(expand('%'))<CR>", { silent = true }) -- Delete file
-- keymap.set('n', '<A-n>', ":new %:h/") -- Create new file

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Cell)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('i', '<A-Up>', "<Esc>0v$:m '<-2<CR>gv=gv<CR><Esc>i<Up>", { silent = true })
keymap.set('i', '<A-Down>', "<Esc>$v$:m '>+1<CR>gv=gv<CR><Esc>i<Up>", { silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Terminal)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function CreateTerminalSession()
  vim.ui.input({ prompt = 'Terminal Session Name:', default = '' }, function(input)
    if input ~= nil then
      if input == "" then
        input = "terminal-session"
      end

      local buffer_exists = false
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.bufname(buf) == input then
          buffer_exists = true
          vim.api.nvim_set_current_buf(buf) -- Foca no buffer existente
          break
        end
      end

      if not buffer_exists then
        vim.cmd('enew')
        vim.cmd('terminal')
        vim.cmd('file ' .. input)
      end
    end
  end)
end

keymap.set('n', '<C-t>', ':lua CreateTerminalSession()<CR>', { noremap = true, silent = true })
keymap.set('t', 'jk', [[<C-\><C-n>]], { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Comment)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<C-_>', ':Comment<CR>', { noremap = true, silent = true })
keymap.set('v', '<C-_>', ':Comment<CR>', { noremap = true, silent = true })
keymap.set('i', '<C-_>', '<C-o>:Comment<CR>', { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Window)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Mapeia Shift + k para rolar a tela para cima sem mover o cursor
keymap.set('n', 'J', '<C-y>', { noremap = true, silent = true })

-- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor
keymap.set('n', 'K', '<C-e>', { noremap = true, silent = true })

-- Mapeia Shift + k para rolar a tela para cima sem mover o cursor no modo Visual 
keymap.set('v', 'J', '<C-y>', { noremap = true, silent = true })

-- Mapeia Shift + j para rolar a tela para baixo sem mover o cursor no modo Visual
keymap.set('v', 'K', '<C-e>', { noremap = true, silent = true })


-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Move Window)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', 'm', ':set wrap!<CR>', { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Utils)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

keymap.set('n', '//', ':noh<CR>', { noremap = true, silent = true })
keymap.set('i', '', '<C-o><cmd>w<CR>', { noremap = false, silent = true })
-- keymap.set('n', 's', ":HopWord<CR>", { noremap = true, silent = true })
-- keymap.set('v', 's', ":HopWord<CR>", { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Unammed Tabs)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>n', ':enew<CR>', { noremap = false, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Git Tools)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>ms', ':G<CR>', { noremap = true, silent = true })  -- Git status
keymap.set('n', '<leader>md', ':Gvdiffsplit<CR>', { noremap = true, silent = true })  -- Diferença de versões

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Markdown Tools)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>p', ':MarkdownPreview<CR>', { noremap = true, silent = true })  --MarkDownPreview

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Leap)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>sw", function()
    local target_windows = require('leap.util').get_enterable_windows()
    local targets = {}
    for _, win in ipairs(target_windows) do
      local wininfo = vim.fn.getwininfo(win)[1]
      local pos = { wininfo.topline, 1 }  -- customize the position of the label here
      table.insert(targets, { pos = pos, wininfo = wininfo })
    end

    require('leap').leap {
      target_windows = target_windows, targets = targets,
      action = function (t) vim.api.nvim_set_current_win(t.wininfo.winid) end
    }
  end, { noremap = false, silent = true }
)

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Visual Multi)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<C-c>', '"+<Plug>(VM-Yank)<Plug>(VM-Exit)', { noremap = false, silent = true })
keymap.set('i', '<A-s>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)s<Plug>(VM-Exit)', { noremap = false, silent = true })
keymap.set('i', '<A-d>', '<Esc><Plug>(VM-Find-Under)<Plug>(VM-Case-Conversion-Menu)P<Plug>(VM-Exit)', { noremap = false, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Trouble)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Mapeia a função para uma tecla (por exemplo, Alt + e)
keymap.set('n', 'e', ':lua vim.diagnostic.open_float(nil, { focusable = false })<CR>', { noremap = true, silent = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Obsidian)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>o', ':ObsidianOpen<CR>', { noremap = true, silent = true })


