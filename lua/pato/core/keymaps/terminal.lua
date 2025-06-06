--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(Terminal)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

function CreateTerminalSession()
  vim.ui.input({ prompt = 'Terminal Session Name:', default = '' }, function(input)
    if input ~= nil then
      if input == "" then
        input = "terminal-session"
      end

      local buffer_exists = false
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.fn.bufname(buf) == input then
          buffer_exists = true
          vim.api.nvim_set_current_buf(buf) -- Foca no buffer existente
          break
        end
      end

      if not buffer_exists then
        vim.cmd('enew')
        vim.cmd('terminal')
        vim.cmd('file ' .. input)
      end
    end
  end)
end

Km.set('n', '<C-t>', ':lua CreateTerminalSession()<CR>', { noremap = true, silent = true })
Km.set('t', 'jk', [[<C-\><C-n>]], { noremap = true, silent = true })
