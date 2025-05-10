return{
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-telescope/telescope-dap.nvim",
    "kristijanhusak/vim-dadbod-ui",
  },
  config = function()
    require('telescope').load_extension('dap')
  end
}
