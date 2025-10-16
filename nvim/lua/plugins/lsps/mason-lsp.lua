return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		local mason_lspconfig = require("mason-lspconfig")

		mason_lspconfig.setup({
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"pyright",
				"bashls",
				"lua_ls",
				"graphql",
				"emmet_language_server",
				"prismals",
				"markdown_oxide",
				"yamlls",
				"terraformls",
			},
		})
	end,
}
