return {
  'mg979/vim-visual-multi',
  config = function ()

    vim.g.VM_theme = 'purplegray'
    vim.g.VM_persistent_registers = true
    vim.g.VM_use_system_clipboard = true

    local group = vim.api.nvim_create_augroup("PatoVisualMultiDynamicMaps", { clear = true })

    local function set_vm_maps(bufnr)
      local keymapOpts = { buffer = bufnr, noremap = true, silent = true }
      
      vim.keymap.set('n', 'i', '<Plug>(VM-a)', keymapOpts)
      vim.keymap.set('n', '<C-c>', '"+<Plug>(VM-Yank)<Plug>(VM-Exit)', keymapOpts)
      vim.keymap.set('n', 'k','<Plug>(VM-Motion-j)', keymapOpts)
      vim.keymap.set('n', 'j','<Plug>(VM-Motion-k)', keymapOpts)
      vim.keymap.set('n', 'J','<C-y>', keymapOpts)
      vim.keymap.set('n', 'K','<C-e>', keymapOpts)
      vim.keymap.set('n', '<C-l>','<Plug>(VM-Motion-w)', keymapOpts)
      vim.keymap.set('n', '<C-h>','<Plug>(VM-Motion-b)', keymapOpts)
    end

    local function del_vm_maps(bufnr)
      pcall(vim.keymap.del, 'n', 'i', { buffer = bufnr })
      pcall(vim.keymap.del, 'n', '<C-c>', { buffer = bufnr })
      pcall(vim.keymap.del, 'n', 'k', {buffer = bufnr })
      pcall(vim.keymap.del, 'n', 'j', { buffer = bufnr })
      pcall(vim.keymap.del, 'n', 'J', { buffer = bufnr })
      pcall(vim.keymap.del, 'n', 'K', { buffer = bufnr })
    end

    -- Quando entrar no Visual Multi
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "visual_multi_start",
      callback = function(ev)
        local bufnr = ev.buf or vim.api.nvim_get_current_buf()
        set_vm_maps(bufnr)
      end,
    })

    -- Quando sair do Visual Multi
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "visual_multi_exit",
      callback = function(ev)
        local bufnr = ev.buf or vim.api.nvim_get_current_buf()
        del_vm_maps(bufnr)
      end,
    })

  end
}

