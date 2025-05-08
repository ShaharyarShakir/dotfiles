return {
	"stevearc/oil.nvim",
	enabled = true,
	config = function()
		require("oil").setup({
			default_file_explorer = true, -- start up nvim with oil instead of netrw
			columns = {},
			keymaps = {
				["<C-h>"] = false,
				["<C-c>"] = false, -- prevent from closing Oil as <C-c> is esc key
				["<M-h>"] = "actions.select_split",
				["q"] = "actions.close",
			},
			delete_to_trash = true,
			view_options = {
				show_hidden = true,
			},
			skip_confirm_for_simple_edits = true,
		})
		vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

		vim.keymap.set("n", "<leader>o", require("oil").toggle_float)
	end,
}
