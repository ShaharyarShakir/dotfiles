return {
	"brneor/gitui.nvim",
	config = function()
		--keymaps

		vim.keymap.set("n", "<leader>gg", ":GitUi<CR>", {})
	end,
}
