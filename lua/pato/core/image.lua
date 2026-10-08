local M = {}

-- Extensões abertas como imagem (svg fica de fora: é texto e pode ser editado)
M.extensions = { "png", "jpg", "jpeg", "gif", "webp", "bmp", "ico", "tiff", "tif", "heic", "avif" }

-- Fração da janela que a imagem pode ocupar no kitty (imagens pequenas ampliam até ela)
M.zoom = 0.45

local view_script = vim.fs.joinpath(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)), "image-view.sh")

local function in_kitty()
  return vim.env.KITTY_WINDOW_ID ~= nil and vim.fn.executable("kitten") == 1
end

function M.is_image(path)
  local ext = vim.fn.fnamemodify(path, ":e"):lower()
  return vim.tbl_contains(M.extensions, ext)
end

-- Abre no visualizador de imagens do sistema
function M.open_system(path)
  local opener = vim.fn.has("mac") == 1 and "open" or "xdg-open"
  vim.system({ opener, path }, { detach = true })
end

-- Dentro do kitty abre um overlay sobre a janela do neovim com `kitten icat`
-- (protocolo gráfico do kitty). Qualquer tecla fecha. Fora do kitty, ou se o
-- remote control falhar, usa o visualizador do sistema
function M.open(path)
  path = vim.fn.fnamemodify(path, ":p")
  if not in_kitty() then
    M.open_system(path)
    return
  end
  -- image-view.sh mede o overlay por dentro e redimensiona a imagem para M.zoom dele
  local cmd = {
    "kitty", "@", "launch", "--type=overlay", "--title", vim.fn.fnamemodify(path, ":t"),
    "sh", view_script, path, tostring(math.floor(M.zoom * 100)),
  }
  vim.system(cmd, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function() M.open_system(path) end)
    end
  end)
end

function M.setup()
  local patterns = {}
  for _, ext in ipairs(M.extensions) do
    table.insert(patterns, "*." .. ext)
    table.insert(patterns, "*." .. ext:upper())
  end

  -- Qualquer forma de abrir uma imagem (:e, Telescope, oil) mostra a imagem em vez
  -- do binário e devolve a janela para o buffer anterior
  vim.api.nvim_create_autocmd("BufReadCmd", {
    group    = vim.api.nvim_create_augroup("pato_image", { clear = true }),
    pattern  = patterns,
    callback = function(args)
      local buf = args.buf
      -- Em sistemas case-insensitive *.png e *.PNG casam o mesmo arquivo
      if vim.b[buf].pato_image then return end
      vim.b[buf].pato_image = true
      M.open(args.file)
      vim.bo[buf].buftype   = "nofile"
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].swapfile  = false
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Imagem aberta fora do buffer: " .. args.file })
      vim.bo[buf].modifiable = false
      vim.schedule(function()
        local alt = vim.fn.bufnr("#")
        if alt > 0 and alt ~= buf and vim.api.nvim_buf_is_valid(alt) then
          for _, win in ipairs(vim.fn.win_findbuf(buf)) do
            vim.api.nvim_win_set_buf(win, alt)
          end
        end
      end)
    end,
  })
end

return M
