return {
	"williamboman/mason-lspconfig.nvim",
	lazy = false,
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		local mason_lspconfig = require("mason-lspconfig")

		mason_lspconfig.setup({
			ensure_installed = {
				-- "ts_ls",
				-- "html",
				-- "cssls",
				--				"clangd",
				--[[ "tailwindcss", ]]
				---				"svelte",
				-- "pyright",
				-- "gopls",
				"bashls",
				"lua_ls",
				---				"graphql",
				---				"jdtls",
				--[[ "emmet_ls", ]]
				---				"prismals",
				"markdown_oxide",
				"yamlls",
				"dockerls",
				"docker_compose_language_service"
			},
		})
	end,
}
