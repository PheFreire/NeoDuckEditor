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

    -- resolve o venv de um projeto poetry (criado fora do projeto por padrão)
    -- para que o pyright consiga indexar site-packages e navegar até elas
    local function poetry_venv_python(root_dir)
      if not root_dir or vim.fn.filereadable(root_dir .. "/pyproject.toml") == 0 then
        return nil
      end
      if vim.fn.executable("poetry") == 0 then
        return nil
      end
      local out = vim.fn.system({ "poetry", "env", "info", "--path", "--directory", root_dir })
      if vim.v.shell_error ~= 0 then
        return nil
      end
      out = vim.trim(out)
      local python = out ~= "" and (out .. "/bin/python") or nil
      if not python or vim.fn.executable(python) == 0 then
        return nil
      end
      return python
    end

    vim.lsp.config("pyright", {
      capabilities = capabilities,
      before_init = function(_, config)
        local python_path = poetry_venv_python(config.root_dir)
        if python_path then
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            python = { pythonPath = python_path },
          })
        end
      end,
      on_attach = function(client, bufnr)
        for _, c in pairs(vim.lsp.get_clients()) do
          if c.name == "pyright" and c.id ~= client.id and c.config.root_dir == client.config.root_dir then
            c.stop()
          end
        end
        local python_path = client.config.settings and client.config.settings.python and client.config.settings.python.pythonPath
        if python_path then
          vim.notify("✅ Pyright attached (venv: " .. python_path .. ")")
        else
          vim.notify("✅ Pyright attached (venv não detectado — usando interpretador padrão)")
        end
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

    -- pylsp: somente hover (jedi_hover) — sem diagnostics, sem completion, sem formatting
    vim.lsp.config("pylsp", {
      handlers = {
        -- descarta diagnostics do pylsp para não duplicar os do pyright
        ["textDocument/publishDiagnostics"] = function() end,
      },
      on_attach = function(client, _)
        local caps = client.server_capabilities
        caps.completionProvider          = nil
        caps.signatureHelpProvider       = nil
        caps.definitionProvider          = nil
        caps.typeDefinitionProvider      = nil
        caps.declarationProvider         = nil
        caps.implementationProvider      = nil
        caps.referencesProvider          = nil
        caps.documentHighlightProvider   = nil
        caps.documentSymbolProvider      = nil
        caps.workspaceSymbolProvider     = nil
        caps.codeActionProvider          = nil
        caps.codeLensProvider            = nil
        caps.documentFormattingProvider  = nil
        caps.documentRangeFormattingProvider = nil
        caps.renameProvider              = nil
        caps.foldingRangeProvider        = nil
        caps.selectionRangeProvider      = nil
        caps.inlayHintProvider           = nil
        -- hoverProvider fica intacto
      end,
      settings = {
        pylsp = {
          plugins = {
            jedi_completion     = { enabled = false },
            jedi_definition     = { enabled = false },
            jedi_references     = { enabled = false },
            jedi_signature_help = { enabled = false },
            jedi_symbols        = { enabled = false },
            autopep8            = { enabled = false },
            flake8              = { enabled = false },
            mccabe              = { enabled = false },
            preload             = { enabled = false },
            pycodestyle         = { enabled = false },
            pydocstyle          = { enabled = false },
            pyflakes            = { enabled = false },
            pylint              = { enabled = false },
            rope_autoimport     = { enabled = false },
            rope_completion     = { enabled = false },
            yapf                = { enabled = false },
            -- jedi_hover habilitado por padrão (não precisa declarar)
          },
        },
      },
    })

    -- instala docstring-to-markdown no venv do pylsp gerenciado pelo Mason (uma só vez)
    local pylsp_pip = vim.fn.expand("~/.local/share/nvim/mason/packages/python-lsp-server/venv/bin/pip")
    if vim.fn.executable(pylsp_pip) == 1 then
      local installed = vim.fn.system(pylsp_pip .. " show docstring-to-markdown 2>&1")
      if not installed:match("Name:") then
        vim.fn.jobstart({ pylsp_pip, "install", "docstring-to-markdown" }, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("docstring-to-markdown instalado no venv do pylsp", vim.log.levels.INFO)
            end
          end,
        })
      end
    end

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
			clangd = {
				cmd = {
					"clangd",
					"--enable-config",
					"--background-index",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--clang-tidy",
				},
			},
			pyright = {},
			pylsp = {},
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
