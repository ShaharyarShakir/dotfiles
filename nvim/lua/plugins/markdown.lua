return {
	-- render-markdown.nvim
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = true,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		init = function()
			-- Define background colors and foreground
			local color_fg = "#1F2335"
			local colors = {
				"#ff757f", -- 1
				"#4fd6be", -- 2
				"#7dcfff", -- 3
				"#ff9e64", -- 4
				"#7aa2f7", -- 5
				"#c0caf5", -- 6
			}

			for i, bg in ipairs(colors) do
				vim.cmd(string.format("highlight Headline%dBg guifg=%s guibg=%s gui=bold", i, color_fg, bg))
				-- Optional: define foreground highlights if needed later
				-- vim.cmd(string.format("highlight Headline%dFg guifg=%s gui=bold", i, bg))
			end
		end,
		opts = {
			heading = {
				sign = false,
				icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
				backgrounds = {
					"Headline1Bg",
					"Headline2Bg",
					"Headline3Bg",
					"Headline4Bg",
					"Headline5Bg",
					"Headline6Bg",
				},
				foregrounds = {
					"Headline1Fg",
					"Headline2Fg",
					"Headline3Fg",
					"Headline4Fg",
					"Headline5Fg",
					"Headline6Fg",
				},
			},
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},
			bullet = {
				enabled = true,
			},
			-- checkbox = { ... }  -- Uncomment and configure if needed
		},
	},

	-- markdown-preview.nvim (minimal and automatic install)

	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.keymap.set("n", "<leader>M", "<cmd>MarkdownPreview<cr>", { desc = "Markdown Preview" })
		end,
	},
}
