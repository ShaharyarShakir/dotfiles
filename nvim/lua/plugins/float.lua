return{
	"voldikss/vim-floaterm",
	config = function ()
		vim.keymap.set('n', '<leader>t', ":FloatermNew <CR>", {})
		vim.keymap.set('n', '<leader>t', ":FloatermToggle <CR>", {})
		
	end
}
