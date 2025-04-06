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
				"lua_ls",
				"graphql",
				"jdtls",
				"emmet_ls",
				"prismals",
				"pyright",
				"markdown_oxide",
			},
		})
	end,
}
