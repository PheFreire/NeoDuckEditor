-- Documentações pessoais, acessíveis de qualquer projeto:
--   :Doc     (:doc)   -> telescope filtrando pelo nome dos arquivos
--   :DocTxt  (:docs)  -> telescope filtrando pelo conteúdo dos arquivos
--   :DocDir  (:docd)  -> oil aberto na raiz do diretório de docs

local M = {}

M.root = vim.fs.joinpath(vim.fn.stdpath("config"), "doc")

local function ensure_root()
  if vim.fn.isdirectory(M.root) == 0 then
    vim.fn.mkdir(M.root, "p")
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

function M.setup()
  ensure_root()

  vim.api.nvim_create_user_command("Doc", function()
    require("telescope.builtin").find_files({
      prompt_title = "Docs",
      cwd = M.root,
    })
  end, { desc = "Buscar documentação pelo nome do arquivo" })

  vim.api.nvim_create_user_command("DocTxt", function()
    require("telescope.builtin").live_grep({
      prompt_title = "Docs (texto)",
      cwd = M.root,
    })
  end, { desc = "Buscar documentação pelo conteúdo" })

  vim.api.nvim_create_user_command("DocDir", function()
    local opts = require("pato.plugins.ui.oil").opts
    vim.cmd("vsplit")
    require("oil").open(M.root, opts)
  end, { desc = "Abrir diretório de documentações no oil (split vertical)" })

  cmd_abbrev("doc", "Doc")
  cmd_abbrev("docs", "DocTxt")
  cmd_abbrev("docd", "DocDir")
end

return M
