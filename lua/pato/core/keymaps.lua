-- Set leader key to space
vim.g.mapleader = " "
local keymap = vim.keymap

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "k", "<Down>", { noremap = true, silent = true })
keymap.set("n", "j", "<Up>", { noremap = true, silent = true })
keymap.set("n", "<C-l>", "1000000<Right>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", "1000000<Left>", { noremap = true, silent = true })
keymap.set("n", "<C-k>", "1000000<Down>", { noremap = true, silent = true })
keymap.set("n", "<C-j>", "1000000<Up>", { noremap = true, silent = true })
keymap.set("n", "<C-q>", ":q!<CR>") -- quit without saving
keymap.set("n", "<C-s>", ":w<CR>") -- save
keymap.set('n', '<leader>gb', ':e#<CR>', { silent = true }) -- Open last buffer

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps visual-mode)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("v", "k", "<Down>", { noremap = true, silent = true })
keymap.set("v", "j", "<Up>", { noremap = true, silent = true })
keymap.set("v", "<C-l>", "100000000<Right>", { noremap = true, silent = true })
keymap.set("v", "<C-h>", "100000000<Left>", { noremap = true, silent = true })
keymap.set("v", "<C-k>", "100000000<Down>", { noremap = true, silent = true })
keymap.set("v", "<C-j>", "100000000<Up>", { noremap = true, silent = true })
keymap.set('v', '<BS>', '"_d', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(General keymaps editor-model)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("i", "jk", "<ESC>") -- exit insert mode with jk 
keymap.set('i', '<C-H>', '<C-w>', { noremap = true, silent = true }) -- Delete word with Crtl
vim.api.nvim_set_keymap('i', '<C-Left>', '<Esc>bi', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-Right>', '<Esc>ea', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Split window management)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>s", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>ss", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
keymap.set("n", "<leader>sj", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>sk", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>5") -- make split windows width bigger 
keymap.set("n", "<leader>sh", "<C-w><5") -- make split windows width smaller
keymap.set(
  "n", "<leader>sw", function()
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
  end
)

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Tab Management)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open a new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close a tab
keymap.set("n", "<leader>l", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>h", ":tabp<CR>") -- previous tab

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Quickfix)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>qf", ":cfirst<CR>") -- jump to first quickfix list item
keymap.set("n", "<leader>ql", ":clast<CR>") -- jump to last quickfix list item
keymap.set("n", "<leader>qc", ":cclose<CR>") -- close quickfix list
-- keymap.set("n", "<leader>qo", ":copen<CR>") -- open quickfix list
-- keymap.set("n", "<leader>qp", ":cprev<CR>") -- jump to prev quickfix list item
-- keymap.set("n", "<leader>qn", ":cnext<CR>") -- jump to next quickfix list item

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Nvim-tree)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>") -- toggle file explorer
keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>") -- find file in file explorer
keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(LSP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>gg', '<cmd>lua vim.lsp.buf.hover()<CR>') -- Get code definition
keymap.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>') -- Open the code root path script
keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>')
keymap.set('n', '<leader>gs', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
keymap.set('v', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>')

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Clipboard)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('v', '<C-c>', '"+y', { noremap = true }) -- copy to system clipboard
keymap.set('i', '<C-v>', '<Esc>"+p`[v`]vi', { noremap = true }) -- paste system clipboard data
keymap.set('v', '<C-x>', 'c', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Undo/Reundo)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('i', '<C-z>', '<Esc>"+u`[v`]vi', { noremap = true, silent = true })
keymap.set('i', '<A-z>', '<Esc>"+<C-r>`[v`]vi', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Telescope)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<leader>fs', ':lua require"telescope.builtin".grep_string({ hidden = true })<CR>', { noremap = true, silent = true })
keymap.set("n", "<leader>ff", ':lua require"telescope.builtin".find_files({ hidden = true })<CR>', { noremap = true, silent = true, desc = "Fuzzy find files in cwd" })
keymap.set("n", '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(File CRUD)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<C-d>', ":call delete(expand('%'))<CR>", { silent = true }) -- Delete file
keymap.set('n', '<A-n>', ":new %:h/") -- Create new file

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Cell)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('i', '<A-Up>', "<Esc>100000000<Right>100000000<Left>v1000000<Right>:m '<-2<CR>gv=gv<CR><Esc>i<Up>", { silent = true })
keymap.set('i', '<A-Down>', "<Esc>100000000<Right>100000000<Left>v1000000<Right>:m '>+1<CR>gv=gv<CR><Esc>i<Down>", { silent = true })

--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Terminal)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<C-t>', ":terminal<CR>", { silent = true })
keymap.set('t', '<C-t>', [[<C-\><C-n>]], { noremap = true })

-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Comment)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

keymap.set('n', '<C-_>', ':Comment<CR>', { noremap = true, silent = true })
keymap.set('v', '<C-_>', ':Comment<CR>', { noremap = true, silent = true })

 

