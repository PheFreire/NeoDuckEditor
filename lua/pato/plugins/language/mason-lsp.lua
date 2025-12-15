return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason-lspconfig").setup({
			automatic_enable = true,
		})

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.workspace = capabilities.workspace or {}
    capabilities.workspace.didChangeWatchedFiles = capabilities.workspace.didChangeWatchedFiles or {}
    capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        for _, c in pairs(vim.lsp.get_clients()) do
          if c.name == "pyright" and c.id ~= client.id and c.config.root_dir == client.config.root_dir then
            c.stop()
          end
        end
        vim.notify("✅ Pyright attached.")
      end,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            typeCheckingMode = "basic",
            useLibraryCodeForTypes = true,
            extraPaths = { "src" },
            ignore = { "build", "dist", "**/__pycache__/**" },
          },
        },
      },
    })

    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
          lens = { enable = true },
        },
      },
    })

		-- lsp servers
		local servers = {
			-- lua_ls
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = {
								"vim",
								"Snacks",
								"require",
							},
						},
					},
				},
			},
			-- ts_ls
			ts_ls = {
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				init_options = {
					preferences = {
						disableSuggestions = true,
					},
				},
			},
			-- eslint
			eslint = {
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
			},
			-- biome
			biome = {
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
			},
			-- emmet_ls
			emmet_ls = {
				filetypes = {
					"html",
					"htmx",
					"typescriptreact",
					"javascriptreact",
				},
			},
			-- cssls
			cssls = {
				settings = {
					css = {
						validate = true,
						lint = { unknownAtRules = "ignore" },
					},
					scss = {
						validate = true,
						lint = { unknownAtRules = "ignore" },
					},
					less = {
						validate = true,
						lint = { unknownAtRules = "ignore" },
					},
				},
			},
			clangd = {},
			pyright = {},
			html = {},
			tailwindcss = {},
		}

		-- enable lsps
		for server, config in pairs(servers) do
			vim.lsp.config(server, config)
			vim.lsp.enable(server)
		end
	end,
}
