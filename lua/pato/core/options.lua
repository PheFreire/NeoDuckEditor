vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt
local g = vim.g

-- Wrap Configs
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Clipboard
opt.clipboard = 'unnamedplus'

-- Errors
vim.diagnostic.config({
    signs = true,          -- Ativa sinais à esquerda do código para erros
    underline = true,      -- Ativa sublinhado para erros
    update_in_insert = false,
})

-- Updating Default Iskeyword


--
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one


-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

-- disable some default providers
g["loaded_node_provider"] = 0
g["loaded_python3_provider"] = 0
g["loaded_perl_provider"] = 0
g["loaded_ruby_provider"] = 0

-- Ativa o folding baseado em sintaxe
vim.o.foldmethod = 'indent'
vim.o.foldlevelstart = 99  -- Abre todos os folds por padrão
vim.o.foldenable = false  -- Desativa o folding por padrão

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH
