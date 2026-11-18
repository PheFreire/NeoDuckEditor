-- Auto-completion / Snippets
return {
    'hrsh7th/nvim-cmp',
    event = { "InsertEnter" },
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'rafamadriz/friendly-snippets',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'f3fora/cmp-spell',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()
      luasnip.config.setup({})
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = 'menu,menuone,noinsert,noselect',
        },
        mapping = cmp.mapping.preset.insert {
          ['<CR>'] = cmp.mapping.confirm ({
            behavior = cmp.ConfirmBehavior.Insert,
            -- select = true,
            select = false,
          }),
      -- Tab backwards through suggestions or when a snippet is active, tab to the next argument
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- lsp 
          { name = "luasnip" }, -- snippets
          { name = "buffer" }, -- text within current buffer
          { name = "path" }, -- file system paths
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- =-=-=-=-=-=-=-=-=-=-=-=-=-=-(Português em markdown)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

      -- detecta se o markdown está em português comparando palavras comuns das duas línguas
      local pt_words = { "que", "não", "de", "da", "do", "para", "com", "uma", "um", "é", "os", "as", "em", "no", "na", "se", "mais", "por", "você", "quando", "como" }
      local en_words = { "the", "of", "to", "with", "for", "that", "this", "it", "are", "on", "be", "when", "how", "you" }

      local function count_words(text, words)
        local total = 0
        for _, w in ipairs(words) do
          for _ in text:gmatch("%f[%w\128-\255]" .. w .. "%f[^%w\128-\255]") do
            total = total + 1
          end
        end
        return total
      end

      local function detect_portuguese(bufnr)
        local prose, in_fence = {}, false
        for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 300, false)) do
          if line:match("^%s*```") then
            in_fence = not in_fence
          elseif not in_fence then
            prose[#prose + 1] = line:gsub("`[^`]*`", "")
          end
        end
        local text = " " .. table.concat(prose, " "):lower() .. " "
        local accents = select(2, text:gsub("[ãõçáéíóúâêô]", ""))
        local pt = count_words(text, pt_words) + accents
        local en = count_words(text, en_words)
        return pt >= 5 and pt > en * 2
      end

      -- guarda o resultado por buffer e refaz ao salvar, já que um arquivo novo começa vazio
      local function is_portuguese_buffer()
        if vim.b.pt_prose == nil then
          vim.b.pt_prose = detect_portuguese(0)
        end
        return vim.b.pt_prose
      end

      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = { "*.md", "*.markdown" },
        callback = function(ev)
          vim.b[ev.buf].pt_prose = nil
        end,
      })

      -- true quando o cursor está dentro de um bloco ``` ou de um código inline `
      local function in_code()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local fences = 0
        for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, row - 1, false)) do
          if line:match("^%s*```") then fences = fences + 1 end
        end
        if fences % 2 == 1 then return true end
        local before = vim.api.nvim_get_current_line():sub(1, col)
        return select(2, before:gsub("`", "")) % 2 == 1
      end

      local function prose_context()
        return vim.bo.filetype == "markdown" and is_portuguese_buffer() and not in_code()
      end

      -- lista de palavras gerada pelo :PtDictionary, buscada por prefixo com o look
      local pt_list = require("pato.core.pt-dictionary").list
      local has_look = vim.fn.executable("look") == 1

      local pt_key = require("pato.core.pt-dictionary").key

      -- busca pela chave sem acento, então "variav" e "variáv" encontram "variável"
      local function look(prefix)
        -- checa a cada busca para funcionar logo depois do :PtDictionary, sem reiniciar
        if not has_look or vim.uv.fs_stat(pt_list) == nil then return {} end
        local result = vim.system({ "look", pt_key(prefix), pt_list }, { text = true }):wait()
        local words = {}
        for line in (result.stdout or ""):gmatch("[^\n]+") do
          words[#words + 1] = line:match("\t(.+)$")
        end
        return words
      end

      -- completa a palavra pelo começo: "memór" sugere "memória"
      local pt_source = {}
      function pt_source:is_available() return prose_context() end
      function pt_source:get_keyword_pattern() return [[\k\+]] end
      function pt_source:complete(params, callback)
        local word = params.context.cursor_before_line:sub(params.offset)
        if vim.fn.strchars(word) < 3 then
          return callback({ items = {}, isIncomplete = true })
        end
        local capital = word:match("^%u") ~= nil
        -- primeiro as que começam igual ao digitado (com acento), depois as mais curtas
        local typed = vim.fn.tolower(word)
        local found = look(word)
        local exact = {}
        for _, w in ipairs(found) do
          exact[w] = vim.startswith(w, typed)
        end
        table.sort(found, function(a, b)
          if exact[a] ~= exact[b] then return exact[a] end
          if #a ~= #b then return #a < #b end
          return a < b
        end)
        local items = {}
        for i, w in ipairs(found) do
          if i > 30 then break end
          items[#items + 1] = {
            label = capital and (w:gsub("^%l", string.upper)) or w,
            -- o look já filtrou pelo começo, o texto digitado como filtro impede o cmp de descartar por causa do acento
            filterText = word,
            sortText = string.format("%03d", i),
          }
        end
        callback({ items = items, isIncomplete = true })
      end
      cmp.register_source("pt_words", pt_source)

      -- o cmp-spell exige 'spell' ligado, mas o spellsuggest funciona sem ele e assim não sublinha o texto
      require("cmp-spell").is_available = function()
        return vim.bo.filetype == "markdown"
      end

      local prose_sources = {
        { name = "pt_words" },
        {
          name = "spell",
          option = {
            -- mostra "função" ao digitar "funcao", o filtro do cmp descartaria por causa do acento
            keep_all_entries = true,
            preselect_correct_word = false,
            -- só corrige quando a palavra está errada e nenhuma palavra do dicionário começa com ela
            enable_in_context = function(params)
              local word = params.context.cursor_before_line:match("[%w\128-\255]+$")
              return word ~= nil
                and prose_context()
                and not vim.tbl_isempty(vim.spell.check(word))
                and vim.tbl_isempty(look(word))
            end,
          },
        },
      }

      cmp.setup.filetype("markdown", {
        sources = cmp.config.sources(vim.list_extend({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, vim.list_extend(prose_sources, {
          { name = "buffer" },
          { name = "path" },
        }))),
      })
    end,
  }

