return {
	"ggandor/leap.nvim",
	lazy = false,
	dependencies = {
		"tpope/vim-repeat",
	},
	config = function()
		require("leap").setup({
			safe_labels = {},
		})

		vim.keymap.set({ "n", "x", "o" }, "x", "<Plug>(leap-forward)")
		vim.keymap.set({ "n", "x", "o" }, "X", "<Plug>(leap-backward)")
		vim.keymap.set({ "n", "x", "o" }, "gx", "<Plug>(leap-from-window)")
	end,
}
