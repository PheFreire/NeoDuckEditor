return {
	"p00f/clangd_extensions.nvim",
	ft = { "c", "cpp", "objc", "objcpp" },
	config = function()
		require("clangd_extensions").setup({
			inlay_hints = {
				inline = false,
			},
			ast = {
				role_icons = {
					type = "",
					declaration = "",
					expression = "󰆧",
					specifier = "",
					statement = "",
					["template argument"] = "",
				},
				kind_icons = {
					Compound = "",
					Recovery = "",
					TranslationUnit = "",
					PackExpansion = "",
					TemplateTypeParm = "",
					TemplateTemplateParm = "",
					TemplateParamObject = "",
				},
			},
			memory_usage = {
				border = "rounded",
			},
			symbol_info = {
				border = "rounded",
			},
		})
	end,
}
