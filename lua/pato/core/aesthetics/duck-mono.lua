-- colors/duck-mono.lua

local base   = "#11100f"
local accent = "#FFCC33"

local fg  = "#e6e0c2"
local dim = "#2a2927"

-- limpa qualquer tema anterior e registra o nome do colorscheme
vim.cmd("hi clear")
vim.o.background = "dark"
vim.g.colors_name = "duck-mono"

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Básico
hl("Normal",        { fg = fg,  bg = base })
hl("CursorLine",    { bg = dim })
hl("CursorColumn",  { bg = dim })
hl("ColorColumn",   { bg = dim })
hl("Visual",        { bg = "#333022" })
hl("MatchParen",    { fg = accent, bold = true })

-- Linha
hl("LineNr",        { fg = "#5e5a52" })
hl("CursorLineNr",  { fg = accent, bold = true })

-- Separadores / janelas
hl("VertSplit",     { fg = dim, bg = base })
hl("WinSeparator",  { fg = dim, bg = base })

-- Menu pop-up
hl("Pmenu",         { bg = "#1b1a18", fg = fg })
hl("PmenuSel",      { bg = accent,   fg = base })

-- Sintaxe clássica
hl("Comment",       { fg = "#6d6a65", italic = true })
hl("Keyword",       { fg = accent, bold = true })
hl("Type",          { fg = accent })
hl("Statement",     { fg = accent })
hl("Boolean",       { fg = accent })
hl("Function",      { fg = accent })
hl("Identifier",    { fg = fg })
hl("Constant",      { fg = accent })
hl("String",        { fg = "#ccb973" })
hl("Operator",      { fg = accent })

-- Treesitter
hl("@keyword",              { fg = accent, bold = true })
hl("@function",             { fg = accent })
hl("@variable",             { fg = fg })
hl("@variable.builtin",     { fg = "#e78a4e" })
hl("@field",                { fg = "#d8c080" })
hl("@property",             { fg = "#d8c080" })
hl("@parameter",            { fg = "#ccb973" })

-- LSP semantic tokens
hl("@lsp.type.keyword",     { fg = accent, bold = true })
hl("@lsp.type.parameter",   { fg = "#ccb973" })
hl("@lsp.type.property",    { fg = "#d8c080" })
hl("@lsp.type.variable",    { fg = fg })
hl("@lsp.type.function",    { fg = accent })
hl("@lsp.type.method",      { fg = accent })
hl("@lsp.type.enumMember",  { fg = "#e78a4e" })

