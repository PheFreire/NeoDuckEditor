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
      enabled             = true,
      commented           = false,
      virt_text_pos       = "eol",
    })

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
      layouts = {
        {
          elements = {
            { id = "scopes",      size = 0.35 },
            { id = "breakpoints", size = 0.15 },
            { id = "stacks",      size = 0.30 },
            { id = "watches",     size = 0.20 },
          },
          size     = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl",    size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size     = 10,
          position = "bottom",
        },
      },
    })

    dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open()  end
    dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
    dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end

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
