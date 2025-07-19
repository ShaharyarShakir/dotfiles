return {
	"yetone/avante.nvim",
	build = function()
		if vim.fn.has("win32") == 1 then
			return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		else
			return "make"
		end
	end,
	event = "VeryLazy",
	version = false, -- Never set this to "*"
	---@type avante.Config
	opts = {
		provider = "copilot", -- 👈 Use GitHub Copilot as the LLM provider
		providers = {
			copilot = {
				-- You can add optional settings here if needed
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",

		-- Optional but recommended:
		"echasnovski/mini.pick", -- for file_selector mini.pick
		"nvim-telescope/telescope.nvim", -- for file_selector telescope
		"hrsh7th/nvim-cmp", -- autocompletion
		"ibhagwan/fzf-lua", -- file_selector fzf
		"stevearc/dressing.nvim", -- for input provider dressing
		"folke/snacks.nvim", -- for input provider snacks
		"nvim-tree/nvim-web-devicons", -- icons

		-- 🔧 GitHub Copilot support
		{
			"zbirenbaum/copilot.lua",
			config = function()
				require("copilot").setup({
					suggestion = { enabled = false }, -- disable inline suggestions (Avante handles UI)
					panel = { enabled = false }, -- disable Copilot's floating panel
				})
			end,
		},

		-- 🖼️ Optional image pasting
		{
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					use_absolute_path = true,
				},
			},
		},

		-- 📝 Markdown rendering (optional)
		{
			"MeanderingProgrammer/render-markdown.nvim",
			ft = { "markdown", "Avante" },
			opts = {
				file_types = { "markdown", "Avante" },
			},
		},
	},
}
