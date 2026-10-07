local M = {}

M.file = vim.fs.joinpath(vim.fn.stdpath("config"), "web", "sites.md")

local function ensure_file()
  local dir = vim.fs.dirname(M.file)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  if vim.fn.filereadable(M.file) == 0 then
    -- cria com um site de exemplo para mostrar o formato esperado
    vim.fn.writefile({
      "# Exemplo",
      "## GitHub",
      "- [https://github.com]",
      "- pessoal",
    }, M.file)
  end
end

-- expande "lhs" em "rhs" só quando digitado sozinho na linha de comando,
-- sem afetar "lhs" quando aparece como parte de outro comando/argumento
local function cmd_abbrev(lhs, rhs)
  vim.cmd(string.format(
    [[cnoreabbrev <expr> %s (getcmdtype() ==# ':' && getcmdline() ==# '%s') ? '%s' : '%s']],
    lhs, lhs, rhs, lhs
  ))
end

-- formato do sites.md, na ordem em que aparece no telescope:
--   # Seção          -> divisão { section }
--   ## Nome do site  -> site { name, url, profile }
--   - [url]          -> url do site acima
--   - perfil         -> perfil do site acima (opcional, sem ele usa o padrão)
local function read_sites()
  local items, count, site = {}, 0, nil
  for _, line in ipairs(vim.fn.readfile(M.file)) do
    local name = line:match("^##%s+(.-)%s*$")
    local section = line:match("^#%s+(.-)%s*$")
    local item = line:match("^%-%s*(.-)%s*$")
    if name and name ~= "" then
      site = { name = name }
      table.insert(items, site)
    elseif section and section ~= "" then
      site = nil
      -- linha em branco separando um bloco (seção + sites) do anterior
      if #items > 0 then
        table.insert(items, { blank = true })
      end
      table.insert(items, { section = section })
    elseif site and item and item ~= "" then
      local url = item:match("^%[%s*(.-)%s*%]$")
      if url then
        site.url = url
      else
        site.profile = item
      end
    end
  end
  -- sites sem url são descartados
  items = vim.tbl_filter(function(it)
    return not it.name or it.url ~= nil
  end, items)
  for _, it in ipairs(items) do
    if it.url then
      count = count + 1
    end
  end
  return items, count
end

-- cada perfil tem login, cookies e histórico próprios, isolados via variáveis
-- de ambiente que o terminal-browser lê ao subir seu processo em segundo plano.
-- o caminho precisa ser curto porque o socket do processo fica dentro dele e o
-- macOS limita caminhos de socket a ~104 caracteres
M.profiles = vim.fs.joinpath(vim.env.HOME, ".local", "share", "tbp")

local function profile_env(profile)
  if not profile then
    return {}
  end
  local dir = vim.fs.joinpath(M.profiles, (profile:gsub("[^%w_-]", "_")))
  return {
    TERMINAL_BROWSER_APPDATA = vim.fs.joinpath(dir, "appdata"),
    XDG_DATA_HOME = vim.fs.joinpath(dir, "data"),
    XDG_STATE_HOME = vim.fs.joinpath(dir, "state"),
    XDG_RUNTIME_DIR = vim.fs.joinpath(dir, "run"),
  }
end

local function open_site(site)
  -- abre uma nova tab na sessão atual do kitty via remote control
  -- (usa o KITTY_LISTEN_ON herdado da janela onde o neovim está rodando)
  local cmd = { "kitty", "@", "launch", "--type=tab", "--tab-title", site.name }
  for key, value in pairs(profile_env(site.profile)) do
    table.insert(cmd, "--env")
    table.insert(cmd, key .. "=" .. value)
  end
  vim.list_extend(cmd, { "terminal-browser", "open", site.url, "--no-merge" })
  vim.system(cmd, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("Falha ao abrir tab do kitty: " .. (res.stderr or ""), vim.log.levels.ERROR)
      end)
    end
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("WebWrite", function()
    ensure_file()
    vim.cmd("vsplit " .. vim.fn.fnameescape(M.file))
  end, { desc = "Editar lista de sites do terminal-browser" })

  vim.api.nvim_create_user_command("Web", function()
    ensure_file()
    local items, count = read_sites()
    if count == 0 then
      vim.notify("Nenhum site cadastrado, use :webd", vim.log.levels.WARN)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- separadores somem quando há texto no prompt, ficando só os sites
    local sorter = conf.generic_sorter({})
    local score = sorter.scoring_function
    sorter.scoring_function = function(self, prompt, line, entry, ...)
      if not entry.value.url then
        return prompt == "" and 1 or -1
      end
      return score(self, prompt, line, entry, ...)
    end

    local picker = pickers.new({}, {
      prompt_title = "Web",
      -- lista de cima para baixo na mesma ordem do sites.md
      sorting_strategy = "ascending",
      layout_config = { prompt_position = "top" },
      finder = finders.new_table({
        results = items,
        entry_maker = function(item)
          if item.blank then
            return { value = item, ordinal = "", display = "" }
          end
          if item.section then
            local text = "── " .. item.section .. " ──"
            return {
              value = item,
              ordinal = item.section,
              display = function()
                return text, { { { 0, #text }, "Title" } }
              end,
            }
          end
          -- perfil aparece apagado ao lado do nome
          local text = item.profile and (item.name .. "  " .. item.profile) or item.name
          return {
            value = item,
            ordinal = item.name,
            display = function()
              if not item.profile then
                return text
              end
              return text, { { { #item.name + 2, #text }, "Comment" } }
            end,
          }
        end,
      }),
      sorter = sorter,
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          if entry and not entry.value.url then
            return
          end
          actions.close(prompt_bufnr)
          if entry then
            open_site(entry.value)
          end
        end)
        return true
      end,
    })

    -- qualquer movimento (e a seleção inicial) continua na mesma direção
    -- enquanto cair num separador
    local move_selection = picker.move_selection
    picker.move_selection = function(self, change)
      move_selection(self, change)
      local step = change < 0 and -1 or 1
      for _ = 1, self.manager:num_results() do
        local entry = self:get_selection()
        if not entry or entry.value.url then
          return
        end
        move_selection(self, step)
      end
    end
    picker:register_completion_callback(function(self)
      self:move_selection(0)
    end)

    picker:find()
  end, { desc = "Abrir site cadastrado no terminal-browser" })

  cmd_abbrev("webd", "WebWrite")
  cmd_abbrev("web", "Web")
end

return M
