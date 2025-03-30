-- settings.lua
vim.opt.termguicolors = true -- Enable true colors
vim.opt.background = "dark"  -- Set background (can be "light" too)
local o = vim.opt
o.number = true
o.relativenumber = true
 -- clipboard
o.clipboard:append("unnamedplus") -- use system clipboard as default register
-- search settings
o.ignorecase = true -- ignore case when searching
o.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive


