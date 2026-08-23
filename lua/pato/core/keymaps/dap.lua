-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(DAP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

-- Execution flow
Km.set("n", "<leader>dc", function() require("dap").continue() end,           { noremap = true, silent = true, desc = "DAP: Start/Continue" })
Km.set("n", "<leader>ds", function() require("dap").step_over() end,          { noremap = true, silent = true, desc = "DAP: Step Over" })
Km.set("n", "<leader>di", function() require("dap").step_into() end,          { noremap = true, silent = true, desc = "DAP: Step Into" })
Km.set("n", "<leader>do", function() require("dap").step_out() end,           { noremap = true, silent = true, desc = "DAP: Step Out" })
Km.set("n", "<leader>dl", function() require("dap").run_last() end,           { noremap = true, silent = true, desc = "DAP: Run Last" })
Km.set("n", "<leader>dR", function() require("dap").restart() end,            { noremap = true, silent = true, desc = "DAP: Restart" })
Km.set("n", "<leader>dq", function() require("dap").terminate() end,          { noremap = true, silent = true, desc = "DAP: Terminate" })

-- Breakpoints
Km.set("n", "<leader>db", function() require("dap").toggle_breakpoint() end,  { noremap = true, silent = true, desc = "DAP: Toggle Breakpoint" })
Km.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Condition: "))
end,                                                                           { noremap = true, silent = true, desc = "DAP: Conditional Breakpoint" })
Km.set("n", "<leader>dL", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end,                                                                           { noremap = true, silent = true, desc = "DAP: Logpoint" })
Km.set("n", "<leader>dC", function() require("dap").clear_breakpoints() end,  { noremap = true, silent = true, desc = "DAP: Clear All Breakpoints" })

-- UI / Inspect
Km.set("n", "<leader>du", function() require("dapui").toggle() end,           { noremap = true, silent = true, desc = "DAP: Toggle UI (all)" })
Km.set("n", "<leader>dU", function() require("dapui").toggle(2) end,          { noremap = true, silent = true, desc = "DAP: Toggle side panel (scopes/stacks/watches)" })
Km.set("n", "<leader>dg", function() require("dap.ui.widgets").hover() end,   { noremap = true, silent = true, desc = "DAP: Hover variable" })
Km.set("n", "<leader>de", function() require("dapui").eval() end,             { noremap = true, silent = true, desc = "DAP: Eval Expression" })
Km.set("v", "<leader>de", function() require("dapui").eval() end,             { noremap = true, silent = true, desc = "DAP: Eval Selection" })
Km.set("n", "<leader>dr", function() require("dap").repl.open() end,          { noremap = true, silent = true, desc = "DAP: Open REPL" })
