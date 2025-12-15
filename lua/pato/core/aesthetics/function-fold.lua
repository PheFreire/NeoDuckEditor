-- Ativa o folding baseado em sintaxe
vim.opt.fillchars = {
    fold = " ",         -- Remove a linha tracejada
    foldopen = "▾",     -- Seta para baixo quando o fold está aberto
    foldclose = "▸",    -- Seta para a direita quando o fold está fechado
    foldsep = " ",      -- Remove separadores entre folds

    vert = "│",
    vertleft = "│",
    vertright = "│",
    verthoriz = "│",
    eob = " ",
}

function _G.custom_fold_text()
  local line = vim.fn.getline(vim.v.foldstart)
  local num_lines = vim.v.foldend - vim.v.foldstart + 1
  return " ▸ " .. line .. " ▸ " .. num_lines .. " lines "
end

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldenable = true
vim.opt.foldtext = "v:lua.custom_fold_text()"

