-- =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-(DAP)-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Km.set("n", "<F5>",       function() require("dap").continue() end,                                   { noremap = true, silent = true, desc = "DAP: Start/Continue" })
Km.set("n", "<F10>",      function() require("dap").step_over() end,                                  { noremap = true, silent = true, desc = "DAP: Step Over" })
Km.set("n", "<F11>",      function() require("dap").step_into() end,                                  { noremap = true, silent = true, desc = "DAP: Step Into" })
Km.set("n", "<F12>",      function() require("dap").step_out() end,                                   { noremap = true, silent = true, desc = "DAP: Step Out" })
Km.set("n", "<leader>b",  function() require("dap").toggle_breakpoint() end,                          { noremap = true, silent = true, desc = "DAP: Toggle Breakpoint" })
Km.set("n", "<leader>B",  function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end,                                                                                                   { noremap = true, silent = true, desc = "DAP: Conditional Breakpoint" })
Km.set("n", "<leader>du", function() require("dapui").toggle() end,                                   { noremap = true, silent = true, desc = "DAP: Toggle UI" })
Km.set("n", "<leader>dr", function() require("dap").repl.open() end,                                  { noremap = true, silent = true, desc = "DAP: Open REPL" })
Km.set("n", "<leader>dl", function() require("dap").run_last() end,                                   { noremap = true, silent = true, desc = "DAP: Run Last" })
