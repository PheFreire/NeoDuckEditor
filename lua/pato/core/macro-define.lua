local M = {}

local MIN_PAD = 4

function M.align(line1, line2)
  if line2 < line1 then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

  -- remove qualquer \ de continuação já existente antes de recalcular
  for i, line in ipairs(lines) do
    lines[i] = line:gsub("%s*\\%s*$", "")
  end

  -- com apenas uma linha selecionada não há "última linha" a preservar:
  -- a própria linha recebe o \
  local n = #lines
  local align_count = (n == 1) and 1 or (n - 1)

  local max_len = 0
  for i = 1, align_count do
    max_len = math.max(max_len, #lines[i])
  end
  local target_col = max_len + MIN_PAD

  for i = 1, align_count do
    local line = lines[i]
    lines[i] = line .. string.rep(" ", target_col - #line) .. "\\"
  end

  vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

function M.unalign(line1, line2)
  if line2 < line1 then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

  for i, line in ipairs(lines) do
    lines[i] = line:gsub("%s*\\%s*$", "")
  end

  vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

vim.api.nvim_create_user_command("Define", function(opts)
  M.align(opts.line1, opts.line2)
end, { range = true })

vim.api.nvim_create_user_command("Undefine", function(opts)
  M.unalign(opts.line1, opts.line2)
end, { range = true })

-- permite digitar ":define"/":undefine" (minúsculo) em vez de ":Define"/":Undefine",
-- só quando for exatamente o comando (com prefixo de range opcional)
vim.cmd([[
  cnoreabbrev <expr> define ((getcmdtype() ==# ':' && getcmdline() =~# '^\%(''<,''>\)\=define$') ? 'Define' : 'define')
  cnoreabbrev <expr> undefine ((getcmdtype() ==# ':' && getcmdline() =~# '^\%(''<,''>\)\=undefine$') ? 'Undefine' : 'undefine')
]])

return M
