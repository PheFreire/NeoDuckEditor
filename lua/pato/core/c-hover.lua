local M = {}

local bs = string.char(8)

local function strip_overstrike(text)
  return text:gsub("." .. bs, "")
end

local open_lsp_hover_with_toggle  -- forward declaration

local function open_man_float(word, orig_win, on_toggle)
  local output
  for _, sec in ipairs({ "3", "2", "1" }) do
    local result = vim.fn.system("man -P cat " .. sec .. " " .. word .. " 2>/dev/null")
    if result ~= "" and not result:match("^No manual") and not result:match("^man:") then
      output = result
      break
    end
  end

  if not output or output == "" then
    return false
  end

  local lines = vim.split(strip_overstrike(output), "\n")

  local cutoff = math.min(#lines, 80)
  for i, line in ipairs(lines) do
    if i > 10 and line:match("^[A-Z ]+$") then
      local section = line:match("^%s*(.-)%s*$")
      if section == "SEE ALSO" or section == "BUGS" or section == "NOTES" then
        cutoff = i - 1
        break
      end
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  local display_lines = vim.list_slice(lines, 1, cutoff)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)
  vim.bo[buf].modifiable = false

  local width  = math.floor(vim.o.columns * 0.8)
  local height = math.min(cutoff + 2, math.floor(vim.o.lines * 0.6))
  local row    = math.floor((vim.o.lines - height) / 2)
  local col    = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = row,
    col       = col,
    style     = "minimal",
    border    = "rounded",
    title     = " man " .. word .. " ",
    title_pos = "center",
  })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })

  if on_toggle then
    vim.keymap.set("n", "<leader><leader>", function()
      vim.api.nvim_win_close(win, true)
      -- schedule para dar tempo ao Neovim de processar o fechamento
      -- antes de registrar o WinNew e chamar o hover
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(orig_win) then
          vim.api.nvim_set_current_win(orig_win)
        end
        on_toggle()
      end)
    end, { buffer = buf, silent = true, nowait = true })
  end

  return true
end

open_lsp_hover_with_toggle = function(word, orig_win)
  local wins_before = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do wins_before[w] = true end
  local attached = false

  local function attach(hover_win)
    if attached then return end
    attached = true
    local hover_buf = vim.api.nvim_win_get_buf(hover_win)
    vim.keymap.set("n", "<leader><leader>", function()
      if vim.api.nvim_win_is_valid(hover_win) then
        vim.api.nvim_win_close(hover_win, true)
      end
      open_man_float(word, orig_win, function()
        open_lsp_hover_with_toggle(word, orig_win)
      end)
    end, { buffer = hover_buf, silent = true, nowait = true })
  end

  local function find_hover_win()
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if not wins_before[w] and vim.api.nvim_win_is_valid(w) then
        local cfg = vim.api.nvim_win_get_config(w)
        if cfg.relative ~= "" then return w end
      end
    end
  end

  -- caminho rápido via WinNew
  local aug = vim.api.nvim_create_augroup("LspHoverToggle", { clear = true })
  vim.api.nvim_create_autocmd("WinNew", {
    group = aug,
    callback = function()
      vim.schedule(function()
        pcall(vim.api.nvim_del_augroup_by_id, aug)
        local w = find_hover_win()
        if w then attach(w) end
      end)
    end,
  })

  vim.lsp.buf.hover()

  -- fallback: tenta N vezes com intervalo de 60ms caso WinNew dispare
  -- na janela errada ou antes da janela do hover estar em nvim_list_wins
  local function retry(n)
    if attached then return end
    local w = find_hover_win()
    if w then
      pcall(vim.api.nvim_del_augroup_by_id, aug)
      attach(w)
    elseif n > 0 then
      vim.defer_fn(function() retry(n - 1) end, 60)
    end
  end
  vim.defer_fn(function() retry(5) end, 60)
end

function M.hover()
  if vim.bo.filetype ~= "c" then
    vim.lsp.buf.hover()
    return
  end

  local word     = vim.fn.expand("<cword>")
  local orig_win = vim.api.nvim_get_current_win()
  open_lsp_hover_with_toggle(word, orig_win)
end

return M
