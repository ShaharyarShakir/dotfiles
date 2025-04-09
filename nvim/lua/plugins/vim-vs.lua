
return {
  "mg979/vim-visual-multi",
  branch = "master",
  lazy = false, -- Load immediately
  config = function()
    vim.keymap.set('n', '<C-n>', '<Plug>(VM-Start)', { noremap = true, silent = true })
    vim.keymap.set('x', '<C-n>', '<Plug>(VM-Start)', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-d>', '<Plug>(VM-SelectNext)', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-u>', '<Plug>(VM-SelectPrev)', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-Down>', '<Plug>(VM-AddCursorDown)', { noremap = true, silent = true })
    vim.keymap.set('n', '<C-Up>', '<Plug>(VM-AddCursorUp)', { noremap = true, silent = true })
  end
}
