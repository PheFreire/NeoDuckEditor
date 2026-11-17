local hl = vim.api.nvim_set_hl
local cmd = vim.cmd

-- vim.api.nvim_set_hl(0, 'Cursor', { fg = 'black', bg = 'white' })

vim.cmd([[
  highlight WinSeparator guibg=NONE guifg=#393939
]])
cmd([[highlight CursorLineNr guifg = #d8a657]])

-- changing bg and border colors
hl(0, "FloatBorder", { link = "Normal" })
hl(0, "LspInfoBorder", { link = "Normal" })
hl(0, "NormalFloat", { link = "Normal" })
hl(0, "Pmenu", { link = "Normal" })
hl(0, "PmenuSel", { link = "Search" })

-- -- blink cmp
hl(0, "BlinkCmpMenu", { link = "Normal" })
hl(0, "BlinkCmpMenuBorder", { link = "Normal" })
hl(0, "BlinkCmpMenuSelection", { link = "Search" })
hl(0, "BlinkCmpLabelMatch", { link = "Search" })

-- -- snacks dashboard
hl(0, "SnacksDashboardHeader", { fg = "#d8a657" })
hl(0, "SnacksDashboardDesc", { fg = "#83a598" })
hl(0, "SnacksDashboardFooter", { fg = "#d8a657" })
--
-- -- snacks indentline
hl(0, "SnacksIndent1", { fg = "#ea6962" })
hl(0, "SnacksIndent2", { fg = "#d8a657" })
hl(0, "SnacksIndent3", { fg = "#458588" })
hl(0, "SnacksIndent4", { fg = "#8ec07c" })
hl(0, "SnacksIndent5", { fg = "#d3869b" })
hl(0, "SnacksIndent6", { fg = "#e78a4e" })
hl(0, "SnacksIndent7", { fg = "#83a598" })
--
-- -- snacks picker
hl(0, "SnacksPickerDir", { fg = "#928374" })
--
-- dark-duck: o brilho separa o código, a cor fica só para keywords, valores e macros
local duck = {
  recuado = "#8a8580",
  comentario = "#6d6a65",
  valor = "#ffdc9a",
  tipo = "#c2b59b",
  macro = "#efe6d2",
}

local function duck_highlights()
  -- cmake: comandos com a cor das keywords e palavras-chave dos argumentos com a cor dos valores
  hl(0, "@function.builtin.cmake", { link = "@keyword" })
  hl(0, "@function.cmake", { link = "@keyword" })
  hl(0, "@constant.cmake", { link = "@string" })

  if vim.g.colors_name ~= "dark-duck" then
    return
  end

  -- controle de fluxo com a mesma cor das keywords, separado dos valores
  for _, group in ipairs({ "Conditional", "Repeat", "Statement", "@keyword.return", "@keyword.conditional", "@keyword.repeat", "@keyword.function", "@keyword.operator", "@keyword.exception" }) do
    hl(0, group, { link = "@keyword" })
  end

  -- pontuação e operadores recuados, comentários ao fundo
  for _, group in ipairs({ "Operator", "Delimiter", "@operator", "@punctuation", "@punctuation.delimiter", "@punctuation.bracket", "@punctuation.special" }) do
    hl(0, group, { fg = duck.recuado })
  end
  hl(0, "Comment", { fg = duck.comentario, italic = true })
  hl(0, "SpecialComment", { fg = duck.comentario, italic = true })

  -- literais (strings, números, booleanos, constantes) em um único tom
  hl(0, "String", { fg = duck.valor })
  hl(0, "@string", { fg = duck.valor })
  for _, group in ipairs({ "Number", "Float", "Boolean", "Constant", "Character", "@number", "@number.float", "@float", "@boolean", "@constant", "@constant.builtin", "@character" }) do
    hl(0, group, { link = "@string" })
  end

  -- types em um bege apagado, separados só pelo tom
  for _, group in ipairs({ "Type", "Typedef", "Structure", "@type", "@type.builtin", "@type.definition" }) do
    hl(0, group, { fg = duck.tipo })
  end

  -- macros e preprocessor em um branco quente
  for _, group in ipairs({ "PreProc", "Include", "Define", "Macro", "PreCondit", "@include", "@keyword.import", "@keyword.directive", "@keyword.directive.define", "@function.macro", "@constant.macro" }) do
    hl(0, group, { fg = duck.macro })
  end
end
duck_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = duck_highlights })

-- rainbow delimiter
hl(0, "RainbowDelimiter1", { fg = "#ea6962" })
hl(0, "RainbowDelimiter2", { fg = "#d8a657" })
hl(0, "RainbowDelimiter3", { fg = "#458588" })
hl(0, "RainbowDelimiter4", { fg = "#8ec07c" })
hl(0, "RainbowDelimiter5", { fg = "#d3869b" })
hl(0, "RainbowDelimiter6", { fg = "#e78a4e" })
hl(0, "RainbowDelimiter7", { fg = "#83a598" })
