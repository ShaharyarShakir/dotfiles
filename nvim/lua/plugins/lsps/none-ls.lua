return {
	"nvimtools/none-ls.nvim",
	dependencies = {
		"nvimtools/none-ls-extras.nvim",
		"jay-babu/mason-null-ls.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		local formatting = null_ls.builtins.formatting
		local diagnostics = null_ls.builtins.diagnostics

		null_ls.setup({
			sources = {
				formatting.stylua,
				formatting.black,
				formatting.prettier,
				formatting.google_java_format.with({
					command = "google-java-format", -- or "java" if using the jar
					args = {
						"--aosp", -- or "--google-style"
						"-",
					},
					filetypes = { "java" },
				}),
				require("none-ls.diagnostics.eslint_d"),
			},
		})

		vim.keymap.set("n", "<leader>gf", function()
			vim.lsp.buf.format({ async = true })
		end, { desc = "Format with LSP" })
	end,
}
