
return {
  'nvim-lualine/lualine.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('lualine').setup({
      options = {
        icons_enabled = true,           -- Habilitar ícones
        theme = 'nightfly',             -- Tema
        component_separators = '|',     -- Separador de componentes
        section_separators = '',        -- Sem separador de seções
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        always_divide_middle = true,    -- Dividir ao meio
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {
          'branch',
          {
            'diff',
            colored = true, -- Colorir diffs
            diff_color = {
              added = { fg = '#A3BE8C' },   -- Verde para adições
              modified = { fg = '#EBCB8B' }, -- Amarelo para modificações
              removed = { fg = '#BF616A' },  -- Vermelho para remoções
            },
            symbols = { added = '+', modified = '~', removed = '-' }, -- Símbolos Git
          },
          {
            'diagnostics',
            sources = { 'nvim_lsp' },
            sections = { 'error', 'warn', 'info', 'hint' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' }, -- Ícones personalizados
            colored = true,
            update_in_insert = false,
          },
        },
        lualine_c = {
          { 'filename', path = 1, file_status = true, icons_enabled = true },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
  opts = function(_, opts)
    -- Certifique-se de que 'sections' está definido
    if not opts.sections then
      opts.sections = {}
    end
    if not opts.sections.lualine_c then
      opts.sections.lualine_c = {}
    end

    -- Agora adicione o que for necessário
    local trouble = require("trouble")
    local symbols = trouble.statusline({
      mode = "lsp_document_symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
    })
    table.insert(opts.sections.lualine_c, {
      symbols.get,
      cond = symbols.has,
    })
  end,
}
