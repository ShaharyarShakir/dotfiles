return {
	"mg979/vim-visual-multi",
	branch = "master",
	lazy = false, -- Load immediately
	config = function()
		local keymap = vim.keymap.set
		local opts = { noremap = true, silent = true }

		-- Use <leader>n to start multi-selection on word under cursor
		keymap("n", "<leader>n", "<Plug>(VM-Find-Under)", opts)
		keymap("x", "<leader>n", "<Plug>(VM-Find-Subword-Under)", opts)

		-- Select next and previous occurrences
		keymap("n", "<leader>d", "<Plug>(VM-SelectNext)", opts)
		keymap("n", "<leader>u", "<Plug>(VM-SelectPrev)", opts)

		-- Add cursors up/down
		keymap("n", "<leader>j", "<Plug>(VM-AddCursorDown)", opts)
		keymap("n", "<leader>k", "<Plug>(VM-AddCursorUp)", opts)
	end,
}
