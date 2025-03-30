return{
	"voldikss/vim-floaterm",
	config = function ()
		vim.keymap.set('n', '<leader>f', ":FloatermNew <CR>", {})
		vim.keymap.set('n', '<leader>ff', ":FloatermToggle <CR>", {})
		
	end
}
