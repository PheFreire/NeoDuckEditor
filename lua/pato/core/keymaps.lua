-- Set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

-- General keymaps
keymap.set("n", "k", "<Down>", { noremap = true, silent = true })
keymap.set("n", "j", "<Up>", { noremap = true, silent = true })
keymap.set("n", "<C-l>", "1000000<Right>", { noremap = true, silent = true })
keymap.set("n", "<C-h>", "1000000<Left>", { noremap = true, silent = true })
keymap.set("n", "<C-k>", "1000000<Down>", { noremap = true, silent = true })
keymap.set("n", "<C-j>", "1000000<Up>", { noremap = true, silent = true })

keymap.set("v", "k", "<Down>", { noremap = true, silent = true })
keymap.set("v", "j", "<Up>", { noremap = true, silent = true })
keymap.set("v", "<C-l>", "1000000<Right>", { noremap = true, silent = true })
keymap.set("v", "<C-h>", "1000000<Left>", { noremap = true, silent = true })
keymap.set("v", "<C-k>", "1000000<Down>", { noremap = true, silent = true })
keymap.set("v", "<C-j>", "1000000<Up>", { noremap = true, silent = true })

keymap.set("i", "jk", "<ESC>") -- exit insert mode with jk 
keymap.set("n", "<C-sq>", ":wq<CR>") -- save and quit
keymap.set("n", "<C-q>", ":q!<CR>") -- quit without saving
keymap.set("n", "<C-s>", ":w<CR>") -- save

-- Split window management
keymap.set("n", "<leader>s", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>ss", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>sx", ":close<CR>") -- close split window
-- keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width
keymap.set("n", "<leader>sw", function()
  target_windows = require('leap.util').get_enterable_windows()
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
end) -- Choose between windows
keymap.set("n", "<leader>sj", "<C-w>-") -- make split window height shorter
keymap.set("n", "<leader>sk", "<C-w>+") -- make split windows height taller
keymap.set("n", "<leader>sl", "<C-w>>5") -- make split windows width bigger 
keymap.set("n", "<leader>sh", "<C-w><5") -- make split windows width smaller

-- Tab management
keymap.set("n", "<leader>to", ":tabnew<CR>") -- open a new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close a tab
keymap.set("n", "<leader>l", ":tabn<CR>") -- next tab
keymap.set("n", "<leader>h", ":tabp<CR>") -- previous tab

-- Diff keymaps
-- keymap.set("n", "<leader>cc", ":diffput<CR>") -- put diff from current to other during diff
-- keymap.set("n", "<leader>cj", ":diffget 1<CR>") -- get diff from left (local) during merge
-- keymap.set("n", "<leader>ck", ":diffget 3<CR>") -- get diff from right (remote) during merge
-- keymap.set("n", "<leader>cn", "]c") -- next diff hunk
-- keymap.set("n", "<leader>cp", "[c") -- previous diff hunk

-- Quickfix keymaps
-- keymap.set("n", "<leader>qo", ":copen<CR>") -- open quickfix list
-- keymap.set("n", "<leader>qf", ":cfirst<CR>") -- jump to first quickfix list item
-- keymap.set("n", "<leader>qn", ":cnext<CR>") -- jump to next quickfix list item
-- keymap.set("n", "<leader>qp", ":cprev<CR>") -- jump to prev quickfix list item
-- keymap.set("n", "<leader>ql", ":clast<CR>") -- jump to last quickfix list item
-- keymap.set("n", "<leader>qc", ":cclose<CR>") -- close quickfix list

-- Vim-maximizer
-- keymap.set("n", "<leader>ss", ":MaximizerToggle<CR>") -- toggle maximize tab

-- Nvim-tree
keymap.set("n", "<leader>ee", ":NvimTreeToggle<CR>") -- toggle file explorer
keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>") -- find file in file explorer
-- keymap.set("n", "<leader>er", ":NvimTreeFocus<CR>") -- toggle focus to file explorer

-- Git-blame
-- keymap.set("n", "<leader>gb", ":GitBlameToggle<CR>") -- toggle git blame

-- Harpoon
-- keymap.set("n", "<leader>ha", require("harpoon.mark").add_file)
-- keymap.set("n", "<leader>hh", require("harpoon.ui").toggle_quick_menu)
-- keymap.set("n", "<leader>h1", function() require("harpoon.ui").nav_file(1) end)
-- keymap.set("n", "<leader>h2", function() require("harpoon.ui").nav_file(2) end)
-- keymap.set("n", "<leader>h3", function() require("harpoon.ui").nav_file(3) end)
-- keymap.set("n", "<leader>h4", function() require("harpoon.ui").nav_file(4) end)
-- keymap.set("n", "<leader>h5", function() require("harpoon.ui").nav_file(5) end)
-- keymap.set("n", "<leader>h6", function() require("harpoon.ui").nav_file(6) end)
-- keymap.set("n", "<leader>h7", function() require("harpoon.ui").nav_file(7) end)
-- keymap.set("n", "<leader>h8", function() require("harpoon.ui").nav_file(8) end)
-- keymap.set("n", "<leader>h9", function() require("harpoon.ui").nav_file(9) end)

-- LSP
keymap.set('n', '<leader>gg', '<cmd>lua vim.lsp.buf.hover()<CR>') -- Get code definition
keymap.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>') -- Open the code root path script
keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>')
keymap.set('n', '<leader>rr', '<cmd>lua vim.lsp.buf.rename()<CR>')
keymap.set('n', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>')
keymap.set('n', '<leader>ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
keymap.set('n', '<leader>tr', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
keymap.set('n', '<leader>gt', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
-- keymap.set('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>') 
-- keymap.set('n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
-- keymap.set('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
-- keymap.set('n', '<leader>gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
-- keymap.set('v', '<leader>gf', '<cmd>lua vim.lsp.buf.format({async = true})<CR>')
-- keymap.set('n', '<leader>gl', '<cmd>lua vim.diagnostic.open_float()<CR>')
-- keymap.set('n', '<leader>gp', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
-- keymap.set('n', '<leader>gn', '<cmd>lua vim.diagnostic.goto_next()<CR>')
-- keymap.set('i', '<C-Space>', '<cmd>lua vim.lsp.buf.completion()<CR>')

-- Filetype-specific keymaps (these can be done in the ftplugin directory instead if you prefer)
keymap.set("n", '<leader>oi', function()
  if vim.bo.filetype == 'python' then
    vim.api.nvim_command('PyrightOrganizeImports')
  end
end)


-- Clipboard
vim.keymap.set('v', '<C-c>', '"+y', { noremap = true }) -- copy to system clipboard
vim.keymap.set('i', '<C-v>', '<Esc>"+p`[v`]vi', { noremap = true }) -- paste system clipboard data
vim.keymap.set('v', '<C-x>', 'c', { noremap = true, silent = true }) 

-- Undo/Reundo
vim.keymap.set('i', '<C-z>', '<Esc>"+u`[v`]vi', { noremap = true, silent = true })
vim.keymap.set('n', '<C-z>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('i', '<C-\\>', '<Esc>"+<C-r>`[v`]vi', { noremap = true, silent = true })
vim.keymap.set('n', '<C-f>', '/', { noremap = true, silent = true })

-- Telescope
keymap.set('n', '<leader>fs', ':lua require"telescope.builtin".grep_string({ hidden = true })<CR>', { noremap = true, silent = true })
keymap.set("n", "<leader>ff", ':lua require"telescope.builtin".find_files({ hidden = true })<CR>', { noremap = true, silent = true, desc = "Fuzzy find files in cwd" })

-- Visual mode
keymap.set('v', 'd', '_d')

-- Back to the previous page
keymap.set('n', '<leader>gb', ':e#<CR>', { silent = true })

-- Delete current file
keymap.set('n', '<C-d>', ":call delete(expand('%'))<CR>", { silent = true })

-- Create new file
keymap.set('n', '<C-n>', ":new %:h/")
