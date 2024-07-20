return {
  'sainnhe/gruvbox-material',
  config = function()
    -- Configurações específicas do tema
    vim.g.gruvbox_material_background = 'medium'
    vim.g.gruvbox_material_foreground = 'original' -- 'material' | 'mix' | 'original'
    vim.g.gruvbox_material_enable_bold = 1 -- Habilita negrito
    vim.g.gruvbox_material_enable_italic = 1 -- Habilita itálico
    vim.g.gruvbox_material_transparent_background = 0 -- Fundo não transparente
    vim.cmd('colorscheme gruvbox-material') -- Aplica o esquema de cores
    vim.cmd([[
      highlight NvimTreeNormal guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeEndOfBuffer guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeVertSplit guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeFolderIcon guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeFolderName guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeOpenedFolderName guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeEmptyFolderName guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeExecFile guibg=#32302f guifg=#ebdbb2
      highlight NvimTreeOpenedFile guibg=#32302f guifg=#ebdbb2
    ]])
  end
}
