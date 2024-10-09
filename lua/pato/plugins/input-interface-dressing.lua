return {
  'stevearc/dressing.nvim',
  config = function()
    require('dressing').setup({
      input = {
        -- Ativar o estilo de input que você quiser
        win_options = {
          winblend = 0,  -- Define a opacidade da janela
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
        border = 'rounded',
        relative = "editor",
        prefer_width = 40,
        max_width = { 80, 0.9 },
        min_width = { 20, 0.2 },
        col = 0.5,
        row = 0.5,
        prompt_align = 'center',
      },
      select = {
        backend = { "telescope", "builtin" },
      },

      mappings = {
        n = {
          ["<Esc>"] = "Close",
          ["<CR>"] = "Confirm",
        },
        i = {
          ["<C-c>"] = "Close",
          ["<CR>"] = "Confirm",
          ["<Up>"] = "HistoryPrev",
          ["<Down>"] = "HistoryNext",
        },
      },
    })
  end
}
