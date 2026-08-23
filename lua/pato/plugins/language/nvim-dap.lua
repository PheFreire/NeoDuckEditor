return {
  "mfussenegger/nvim-dap",
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
        -- Layout 2: toggle manual — variáveis, call stack e watches na lateral
        {
          elements = {
            { id = "scopes", size = 0.65 },
            { id = "stacks", size = 0.35 },
          },
          size     = 38,
          position = "left",
        },
      },
    })

    -- Abre layout inferior e devolve foco para a janela do código fonte
    dap.listeners.after.event_initialized["dapui_config"] = function()
      local src_win = vim.api.nvim_get_current_win()
      dapui.open(1)
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(src_win) then
          vim.api.nvim_set_current_win(src_win)
        end
      end)
    end
    dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close()  end
    dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close()  end

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

    dap.configurations.c = {
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
