return {
  "mfussenegger/nvim-dap",
  -- lazy: os keymaps em core/keymaps/dap.lua fazem require("dap") sob demanda
  lazy = true,
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap    = require("dap")
    local dapui  = require("dapui")

    require("mason-nvim-dap").setup({
      ensure_installed    = { "codelldb" },
      automatic_installation = true,
      handlers            = {},
    })

    require("nvim-dap-virtual-text").setup({
      enabled                      = true,
      commented                    = false,
      virt_text_pos                = "eol",
      highlight_changed_variables  = true,
      highlight_new_as_changed     = true,
      show_stop_reason             = true,
      all_references               = false,
      only_first_definition        = true,
    })

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      layouts = {
        -- Layout 1: abre automaticamente — REPL e console lado a lado embaixo
        {
          elements = {
            { id = "console", size = 0.5 },
            { id = "repl",    size = 0.5 },
          },
          size     = 14,
          position = "bottom",
        },
        -- Layout 2: variáveis, watches e call stack na lateral (também abre automaticamente)
        {
          elements = {
            { id = "scopes",  size = 0.55 },
            { id = "watches", size = 0.20 },
            { id = "stacks",  size = 0.25 },
          },
          size     = 38,
          position = "left",
        },
      },
    })

    -- Abre os dois layouts e devolve foco para a janela do código fonte
    dap.listeners.after.event_initialized["dapui_config"] = function()
      local src_win = vim.api.nvim_get_current_win()
      dapui.open()
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(src_win) then
          vim.api.nvim_set_current_win(src_win)
        end
      end)
    end
    dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close()  end
    dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close()  end

    -- nvim-dap preenche buffers dap-src:// como buffers normais, então ficam "modificados"
    -- e bloqueiam :q! (E162). Marca como nofile assim que são carregados. Não usar
    -- bufhidden=wipe: o nvim-dap ainda usa o buffer (diagnóstico da exceção) depois de escondido
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = "dap-src://*",
      callback = function(args)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(args.buf) then return end
          vim.bo[args.buf].buftype   = "nofile"
          vim.bo[args.buf].bufhidden = "hide"
          vim.bo[args.buf].swapfile  = false
          vim.bo[args.buf].modified  = false
        end)
      end,
    })

    -- Impede que buffers dap-src:// apareçam: redireciona a janela para o buffer anterior
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "dap-src://*",
      callback = function()
        vim.schedule(function()
          local alt = vim.fn.bufnr("#")
          if alt > 0 and vim.api.nvim_buf_is_valid(alt) then
            vim.api.nvim_win_set_buf(0, alt)
          end
        end)
      end,
    })

    -- Quando o programa para (crash, sinal, breakpoint) dentro de código sem fonte (libc, asan...),
    -- sobe a call stack até o primeiro frame que é um arquivo seu e mostra o motivo da parada.
    -- A troca espera a resposta de "scopes" do frame do topo: se trocasse antes, essa resposta
    -- chegaria por último e o painel de scopes ficaria vazio
    local pending_user_frame = {}
    local function is_user_file(f)
      local path = f and f.source and f.source.path
      return path and vim.uv.fs_stat(path) ~= nil
    end

    dap.listeners.after.event_stopped["pato_user_frame"] = function(session, body)
      if body.reason == "exception" or body.reason == "signal" then
        local msg = body.description or body.text or body.reason
        vim.notify("Programa parou: " .. msg, vim.log.levels.ERROR, { title = "DAP" })
      end
      pending_user_frame[session.id] = body.threadId
    end

    dap.listeners.after.scopes["pato_user_frame"] = function(session)
      local thread_id = pending_user_frame[session.id]
      if not thread_id then return end
      pending_user_frame[session.id] = nil
      vim.schedule(function()
        local thread = session.threads[thread_id]
        if not thread or not thread.frames or is_user_file(session.current_frame) then return end
        for _, f in ipairs(thread.frames) do
          if is_user_file(f) then
            session:_frame_set(f)
            return
          end
        end
      end)
    end

    -- Stack acompanha o cursor: ao mover o cursor para dentro de uma função que está na
    -- call stack, seleciona aquele frame (como <leader>dk/<leader>dj) sem mover o cursor
    vim.g.dap_follow_cursor = true
    local function enclosing_function(bufnr, row)
      local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, 0 }, ignore_injections = true })
      if not ok then return nil end
      while node do
        if node:type():match("function_definition") or node:type():match("function_declaration") then
          local srow, _, erow = node:range()
          return srow + 1, erow + 1
        end
        node = node:parent()
      end
    end

    -- Caminho canônico (resolve symlinks e ./..) para comparar buffer com source do frame
    local function realpath(p)
      return p and (vim.uv.fs_realpath(p) or vim.fs.normalize(p))
    end

    vim.api.nvim_create_autocmd("CursorMoved", {
      group = vim.api.nvim_create_augroup("pato_dap_follow_cursor", { clear = true }),
      callback = function(ev)
        if not vim.g.dap_follow_cursor then return end
        local session = dap.session()
        if not session or not session.stopped_thread_id then return end
        local thread = session.threads[session.stopped_thread_id]
        if not thread or not thread.frames then return end

        local name = vim.api.nvim_buf_get_name(ev.buf)
        if name == "" or name:match("^%a+://") then return end
        local path = realpath(name)
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local first, last = enclosing_function(ev.buf, row - 1)
        if not first then return end

        for _, f in ipairs(thread.frames) do
          if f.source and realpath(f.source.path) == path and f.line >= first and f.line <= last then
            if not session.current_frame or session.current_frame.id ~= f.id then
              session.current_frame = f
              session:_request_scopes(f)
            end
            return
          end
        end
      end,
    })

    -- Funções na call stack ficam sublinhadas: o nome da função e a linha onde a execução
    -- está dentro dela. O frame selecionado (o que aparece em scopes) usa outra cor
    local stack_ns = vim.api.nvim_create_namespace("pato_dap_stack")

    local function function_name_node(bufnr, row)
      local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, 0 }, ignore_injections = true })
      if not ok then return nil end
      while node and not node:type():match("function_definition") do
        node = node:parent()
      end
      -- function_definition > (pointer_declarator >)* function_declarator > identifier
      local decl = node and node:field("declarator")[1]
      while decl and decl:type() ~= "function_declarator" do
        decl = decl:field("declarator")[1]
      end
      return decl and decl:field("declarator")[1]
    end

    local function buf_for_path(path)
      local target = realpath(path)
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(b) and realpath(vim.api.nvim_buf_get_name(b)) == target then
          return b
        end
      end
    end

    local function clear_stack_marks()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(b) then
          vim.api.nvim_buf_clear_namespace(b, stack_ns, 0, -1)
        end
      end
    end

    local function render_stack_marks()
      clear_stack_marks()
      local session = dap.session()
      if not session or not session.stopped_thread_id then return end
      local thread = session.threads[session.stopped_thread_id]
      if not thread or not thread.frames then return end

      for _, f in ipairs(thread.frames) do
        local path = f.source and f.source.path
        local bufnr = path and f.line > 0 and buf_for_path(path)
        if bufnr then
          local current = session.current_frame and session.current_frame.id == f.id
          local row = f.line - 1
          local text = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
          local first_col = text:find("%S") or 1
          vim.api.nvim_buf_set_extmark(bufnr, stack_ns, row, first_col - 1, {
            end_col  = #text,
            hl_group = current and "DapStackLineCurrent" or "DapStackLine",
            priority = 150,
          })
          local name = function_name_node(bufnr, row)
          if name then
            local srow, scol, erow, ecol = name:range()
            vim.api.nvim_buf_set_extmark(bufnr, stack_ns, srow, scol, {
              end_row  = erow,
              end_col  = ecol,
              hl_group = current and "DapStackFuncCurrent" or "DapStackFunc",
              priority = 150,
            })
          end
        end
      end
    end

    local schedule_render = function() vim.schedule(render_stack_marks) end
    -- "scopes" é pedido a cada parada e a cada troca de frame (dk/dj, cursor, crash)
    dap.listeners.after.scopes["pato_stack_marks"]           = schedule_render
    dap.listeners.after.event_continued["pato_stack_marks"]  = function() vim.schedule(clear_stack_marks) end
    dap.listeners.after.event_terminated["pato_stack_marks"] = function() vim.schedule(clear_stack_marks) end
    dap.listeners.after.event_exited["pato_stack_marks"]     = function() vim.schedule(clear_stack_marks) end
    dap.listeners.after.disconnect["pato_stack_marks"]       = function() vim.schedule(clear_stack_marks) end
    -- Arquivos da stack abertos depois da parada também recebem as marcas
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group    = vim.api.nvim_create_augroup("pato_dap_stack_marks", { clear = true }),
      callback = function() if dap.session() then schedule_render() end end,
    })

    -- Signs para breakpoints (definidos uma vez, signs sobrevivem à troca de tema)
    vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DapBreakpoint",          linehl = "DapBreakpointLine", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "○", texthl = "DapBreakpointCondition",  linehl = "",                 numhl = "" })
    vim.fn.sign_define("DapBreakpointRejected",  { text = "⊘", texthl = "DapBreakpointRejected",   linehl = "",                 numhl = "" })
    vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DapLogPoint",             linehl = "",                 numhl = "" })
    vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DapStopped",              linehl = "DapStoppedLine",   numhl = "" })

    -- Highlights são limpos ao trocar de tema, então reaplicamos via autocmd
    local function set_dap_highlights()
      vim.api.nvim_set_hl(0, "DapBreakpoint",         { fg = "#e06c75" })
      vim.api.nvim_set_hl(0, "DapBreakpointLine",     { bg = "#2d1414" })
      vim.api.nvim_set_hl(0, "DapBreakpointCondition",{ fg = "#e5c07b" })
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#5c6370" })
      vim.api.nvim_set_hl(0, "DapLogPoint",           { fg = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStopped",            { fg = "#FFCC33" })
      vim.api.nvim_set_hl(0, "DapStoppedLine",        { bg = "#2d2600" })
      vim.api.nvim_set_hl(0, "DapStackFunc",          { fg = "#61afef", underline = true, sp = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStackFuncCurrent",   { fg = "#FFCC33", underline = true, sp = "#FFCC33", bold = true })
      vim.api.nvim_set_hl(0, "DapStackLine",          { underline = true, sp = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStackLineCurrent",   { underline = true, sp = "#FFCC33" })
    end

    set_dap_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_dap_highlights,
    })

    local codelldb_bin = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb_bin,
        args    = { "--port", "${port}" },
      },
    }

    -- Compila o arquivo atual com símbolos de debug (-g -O0); sem -g o debugger não
    -- consegue mostrar linhas nem valores de variáveis
    local function compile_current(extra_flags)
      return function()
        vim.cmd("silent! write")
        local src = vim.fn.expand("%:p")
        local out_dir = vim.fn.stdpath("cache") .. "/dap"
        vim.fn.mkdir(out_dir, "p")
        local out = out_dir .. "/" .. vim.fn.expand("%:t:r")
        local cmd = vim.list_extend({ "cc", "-g", "-O0", "-Wall", "-Wextra", "-fno-omit-frame-pointer" }, extra_flags)
        vim.list_extend(cmd, { src, "-o", out })
        local result = vim.system(cmd, { text = true }):wait()
        if result.code ~= 0 then
          vim.notify(result.stderr, vim.log.levels.ERROR, { title = "Compilação falhou" })
          return dap.ABORT
        end
        return out
      end
    end

    dap.configurations.c = {
      {
        name        = "Compile current file & debug",
        type        = "codelldb",
        request     = "launch",
        program     = compile_current({}),
        cwd         = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name        = "Compile current file & debug (AddressSanitizer)",
        type        = "codelldb",
        request     = "launch",
        program     = compile_current({ "-fsanitize=address,undefined" }),
        cwd         = "${workspaceFolder}",
        stopOnEntry = false,
        env         = { ASAN_OPTIONS = "abort_on_error=1:detect_leaks=0" },
      },
      {
        name        = "Launch executable",
        type        = "codelldb",
        request     = "launch",
        program     = function()
          return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd         = "${workspaceFolder}",
        stopOnEntry = false,
        args        = {},
      },
    }
  end,
}
