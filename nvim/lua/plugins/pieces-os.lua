
return {
  "pieces-app/plugin_neovim",
  enabled = false,
  lazy = false, -- load immediately; set to true for lazy loading
  config = function()
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    map("n", "<leader>po", "<cmd>PiecesOpen<CR>", opts)
    map("n", "<leader>pi", "<cmd>PiecesInsert<CR>", opts)
    map("n", "<leader>ps", "<cmd>PiecesSearch<CR>", opts)
    map("n", "<leader>py", "<cmd>PiecesSync<CR>", opts)
  end,
}
