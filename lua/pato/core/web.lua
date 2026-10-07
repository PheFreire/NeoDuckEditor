local M = {}

M.file = vim.fs.joinpath(vim.fn.stdpath("config"), "web", "sites.md")

local function ensure_file()
  local dir = vim.fs.dirname(M.file)
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  if vim.fn.filereadable(M.file) == 0 then
    -- cria com um site de exemplo para mostrar o formato esperado
    vim.fn.writefile({ "# GitHub [https://github.com]" }, M.file)
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

local function read_sites()
  local sites = {}
  for _, line in ipairs(vim.fn.readfile(M.file)) do
    local name, url = line:match("^#%s*(.-)%s*%[%s*(.-)%s*%]%s*$")
    if name and name ~= "" and url ~= "" then
      table.insert(sites, { name = name, url = url })
    end
  end
  return sites
end

local function open_site(url)
  -- abre uma nova tab na sessão atual do kitty via remote control
  -- (usa o KITTY_LISTEN_ON herdado da janela onde o neovim está rodando)
  vim.system({
    "kitty", "@", "launch", "--type=tab", "--tab-title", url,
    "terminal-browser", "open", url, "--no-merge",
  }, { text = true }, function(res)
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
    local sites = read_sites()
    if #sites == 0 then
      vim.notify("Nenhum site cadastrado, use :webd", vim.log.levels.WARN)
      return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
      prompt_title = "Web",
      finder = finders.new_table({
        results = sites,
        entry_maker = function(site)
          return { value = site, display = site.name, ordinal = site.name }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry then
            open_site(entry.value.url)
          end
        end)
        return true
      end,
    }):find()
  end, { desc = "Abrir site cadastrado no terminal-browser" })

  cmd_abbrev("webd", "WebWrite")
  cmd_abbrev("web", "Web")
end

return M
