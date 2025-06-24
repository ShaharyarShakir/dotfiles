return {
	"zbirenbaum/copilot.lua",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			panel = { enabled = false }, -- panel disabled
			suggestion = {
				enabled = true, -- enable inline suggestions
				auto_trigger = true, -- trigger automatically
				debounce = 75,
				keymap = {
					accept = "<C-l>", -- accept suggestion
					next = "<M-]>", -- next suggestion
					prev = "<M-[>", -- previous suggestion
					dismiss = "<C-]>", -- dismiss suggestion
				},
			},
		})
	end,
}
