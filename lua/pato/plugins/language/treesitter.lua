return {
	"nvim-treesitter/nvim-treesitter",
	event = { "BufReadPost", "BufNewFile" },
	dependencies = {
		"windwp/nvim-ts-autotag",
		opts = {},
		ft = {
			"javascriptreact",
			"typescriptreact",
			"javascript",
			"typescript",
			"html",
			"vue",
			"php",
		},
	},
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
      "diff",
      "bash",
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"prisma",
			"markdown",
			"markdown_inline",
			"svelte",
			"graphql",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"cpp",
			"python",
      "rust",
      "regex",
      "toml",
      "xml",
      "scss",
      "go",
      "sql",
      "terraform",
      "printf",
      "luap",
      "luadoc",
      "jsonc",
      "jsdoc"
		},
		sync_install = false,
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
      disable = function(_, bufnr)
          local ok, bt = pcall(function() return vim.bo[bufnr].buftype end)
          if not ok then return true end
          return bt == "nofile" or bt == "prompt" or bt == "nowrite"
        end,
		},
		inndent = {
			enable = true,
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				scope_incremental = false,
			},
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
