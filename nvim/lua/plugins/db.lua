return {
	-- Main dadbod plugin with keymaps
	{
		"tpope/vim-dadbod",
		lazy = true,
		cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
		init = function()
			vim.keymap.set("n", "<leader>du", ":DBUI<CR>", { desc = "Open DBUI" })
			vim.keymap.set("n", "<leader>da", ":DBUIAddConnection<CR>", { desc = "Add DB Connection" })
			vim.keymap.set("n", "<leader>dt", ":DBUIToggle<CR>", { desc = "Toggle DBUI" })
			vim.keymap.set("n", "<leader>dq", ":DB<CR>", { desc = "Execute SQL Query" })
			vim.keymap.set("n", "<leader>ds", ":Telescope dadbod<CR>", { desc = "Telescope DB Browser" })
		end,
	},

	-- UI for dadbod
	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = { "tpope/vim-dadbod" },
		cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection" },
		init = function()
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},

	-- Completion integration with nvim-cmp
	{
		"kristijanhusak/vim-dadbod-completion",
		ft = { "sql", "mysql", "plsql" },
		dependencies = { "tpope/vim-dadbod" },
		config = function()
			local cmp = require("cmp")
			cmp.setup.filetype("sql", {
				sources = cmp.config.sources({
					{ name = "vim-dadbod-completion" },
					{ name = "buffer" },
				}),
			})
		end,
	},

	-- Telescope integration
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"tpope/vim-dadbod",
		},
		config = function()
			require("telescope").load_extension("dadbod")
		end,
	},

	-- Treesitter for SQL and JSON (Mongo/Mongoose)
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			opts.ensure_installed = opts.ensure_installed or {}
			vim.list_extend(opts.ensure_installed, { "sql", "json" })
		end,
	},
}
