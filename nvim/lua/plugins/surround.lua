return {
	"kylechui/nvim-surround",
	event = { "BufReadPre", "BufNewFile" },
	version = "*", -- Use for stability; omit to use `main` branch for the latest features
	config = true,
--	NORMAL mode
--Keybinding	Action	Example
--ys{motion}{char}	Yank + Surround (adds surround)	ysiw" → "word"
--s{old}{new}	Change Surrounding from one to another	cs"' → 'word'
--ds{char}	Delete Surrounding	ds" → word
-- Visual Mode
-- to surround multiple lines 
-- first go to visual mode select the number of line then capital St then add the element

}
