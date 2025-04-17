return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	{
	},
	dependencies = {
		"hrsh7th/cmp-nvim-lsp", -- LSP completion source
	     --"github/copilot.vim",		-- support for github copilot
		"hrsh7th/cmp-buffer", -- Source for text in buffer
		"hrsh7th/cmp-path", -- Source for file system paths
		"saadparwaiz1/cmp_luasnip", -- Snippet completions
		"hrsh7th/cmp-emoji",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*", -- Follow latest major release
			build = "make install_jsregexp", -- Install optional regex support
		},
		"rafamadriz/friendly-snippets", -- Predefined snippets
		"onsails/lspkind.nvim", -- VS Code-like icons
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")
		local lspkind = require("lspkind")

		-- Load VSCode-style snippets
		--TODO:
		--BUG:
		--HACK:
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,preview,noselect",
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous suggestion
				["<C-j>"] = cmp.mapping.select_next_item(), -- Next suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- Show completion menu
				["<C-e>"] = cmp.mapping.abort(), -- Close completion menu
				["<CR>"] = cmp.mapping.confirm({ select = false }), -- Confirm selection
			}),
			-- Sources for autocompletion
			sources = cmp.config.sources({
				{ name = "nvim_lsp" }, -- LSP suggestions
				{ name = "luasnip" }, -- Snippets
				{ name = "buffer" }, -- Buffer text completion
				{ name = "path" }, -- File path completion
				{ name = "emoji" }, -- for emoji
			}),
			-- Configure lspkind for VS Code-like pictograms
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol", -- Show only symbol icons
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
			window = {
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
		})
	end,
}
