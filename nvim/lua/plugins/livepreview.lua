return {
	"brianhuster/live-preview.nvim",
	lazy = true,
	cmd = { "LivePreview" }, -- optional: only loads on command
	dependencies = {
		-- You only need one of these, remove the rest if not using
		"nvim-telescope/telescope.nvim",
		-- "ibhagwan/fzf-lua",
		-- "echasnovski/mini.pick",
	},
	opts = {
		-- Optional config if you want to set default behavior
		-- See: https://github.com/brianhuster/live-preview.nvim#configuration
		--	open_cmd = "xdg-open", -- or "open" on macOS, or your browser CLI
		open_cmd = "cmd.exe /C start", -- This opens the URL in Windows browser from WSL

		port = 3000,     -- change if port is in use
	},
	config = function(_, opts)
		vim.keymap.set("n", "<C-L>", function()
			vim.cmd("LivePreview start")
			vim.fn.jobstart({ "cmd.exe", "/C", "start", "http://localhost:3000" }, { detach = true })
		end, { desc = "Start Live Preview and Open in Browser" })
	end,
}
