-- Gera os arquivos usados pelas sugestões de português em markdown (nvim-cmp: pt_words e cmp-spell)
local M = {}

local site = vim.fn.stdpath("data") .. "/site"
M.spl = site .. "/spell/pt.utf-8.spl"
-- cada linha é "chave<TAB>palavra", com a chave sem acento para a busca ignorar acentos
M.list = vim.fn.stdpath("data") .. "/dictionary/pt_br_index.txt"

local accents = {
  ["á"] = "a", ["à"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a",
  ["é"] = "e", ["è"] = "e", ["ê"] = "e", ["ë"] = "e",
  ["í"] = "i", ["ì"] = "i", ["î"] = "i", ["ï"] = "i",
  ["ó"] = "o", ["ò"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o",
  ["ú"] = "u", ["ù"] = "u", ["û"] = "u", ["ü"] = "u",
  ["ç"] = "c", ["ñ"] = "n",
}

-- "Variável" vira "variavel"
function M.key(word)
  return (vim.fn.tolower(word):gsub("\195[\128-\191]", accents))
end

local spl_url = "https://ftp.nluug.nl/pub/vim/runtime/spell/pt.utf-8.spl"

local function notify(msg, level)
  vim.schedule(function()
    vim.notify("[PtDictionary] " .. msg, level or vim.log.levels.INFO)
  end)
end

-- roda dentro do nvim filho: transforma o :spelldump do buffer atual na lista ordenada de palavras
function M.write_list(path)
  local seen, words = {}, {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    -- "/1" é só português de Portugal, "/2" é só do Brasil, sem marca vale para os dois
    if not line:find("/1$") then
      local word = line:gsub("/2$", "")
      if word:find("^[%a\128-\255]+$") and vim.fn.strchars(word) >= 3 and not seen[word] then
        seen[word] = true
        words[#words + 1] = M.key(word) .. "\t" .. word
      end
    end
  end
  -- ordem por bytes da linha (começa pela chave), a mesma que o look usa na busca binária
  table.sort(words)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(words, path)
end

local function generate_list(on_done)
  notify("gerando a lista de palavras, isso leva alguns segundos...")
  local config = vim.fn.stdpath("config")
  vim.system({
    vim.v.progpath, "--headless", "--clean",
    "--cmd", "set rtp^=" .. site,
    "--cmd", "set rtp^=" .. config,
    "-c", "set spell spelllang=pt_br",
    "-c", "silent spelldump",
    "-c", "lua require('pato.core.pt-dictionary').write_list([[" .. M.list .. "]])",
    "-c", "qa!",
  }, {}, function(result)
    if result.code ~= 0 or vim.fn.filereadable(M.list) == 0 then
      notify("falha ao gerar a lista: " .. (result.stderr or ""), vim.log.levels.ERROR)
      return
    end
    on_done()
  end)
end

local function download_spl(on_done)
  notify("baixando o dicionário pt.utf-8.spl...")
  vim.fn.mkdir(vim.fs.dirname(M.spl), "p")
  vim.system({ "curl", "-fsSL", "-o", M.spl, spl_url }, {}, function(result)
    if result.code ~= 0 then
      vim.schedule(function() vim.fn.delete(M.spl) end)
      notify("falha ao baixar o dicionário: " .. (result.stderr or ""), vim.log.levels.ERROR)
      return
    end
    on_done()
  end)
end

-- force refaz os dois arquivos mesmo se já existirem
function M.build(force)
  local function finish()
    notify("pronto, as sugestões de português já funcionam nos arquivos markdown")
  end
  local function step_list()
    if force or vim.fn.filereadable(M.list) == 0 then
      generate_list(finish)
    else
      finish()
    end
  end
  if force or vim.fn.filereadable(M.spl) == 0 then
    download_spl(step_list)
  else
    step_list()
  end
end

function M.setup()
  vim.api.nvim_create_user_command("PtDictionary", function(opts)
    M.build(opts.bang)
  end, { bang = true, desc = "Baixa e gera o dicionário de português (! refaz tudo)" })

  -- avisa uma vez quando um markdown abre e o dicionário ainda não foi gerado
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    once = true,
    callback = function()
      if vim.fn.filereadable(M.spl) == 0 or vim.fn.filereadable(M.list) == 0 then
        notify("dicionário de português não encontrado, rode :PtDictionary", vim.log.levels.WARN)
      end
    end,
  })
end

return M
