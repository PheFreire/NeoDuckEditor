local opt = vim.opt
local g = vim.g

g.netrw_liststyle = 3

-- Wrap Configs
opt.fileencoding = "utf-8"
opt.wrap = false
opt.linebreak = true
opt.breakindent = true

-- Clipboard
opt.clipboard = "unnamedplus"

opt.ttyfast = true
opt.cursorline = true

opt.iskeyword:remove({ '"', '.', '{', '}', '(', ')', '[', ']', '/', '\\', ':', ';', ',', ' ', ' '})
opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
vim.opt.foldcolumn = "0"
vim.opt.statuscolumn = ""

-- search settings
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.pumheight = 10
opt.cmdheight = 0
opt.conceallevel = 0
opt.showtabline = 1
opt.winborder = "rounded"
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "no" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- Split Windows
opt.splitbelow = true
opt.splitright = true
opt.inccommand = "split"

-- Update and backups
opt.showmode = false
opt.backup = false
opt.writebackup = true
opt.updatetime = 300
opt.timeoutlen = 500
opt.swapfile = false

-- disable some default providers
g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- Browser
vim.g.mkdp_browser = 'chromium' -- 'firefox'

vim.filetype.add({
    pattern = {
      [".*%.envrc"] = "sh",
    },
})

-- add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH
