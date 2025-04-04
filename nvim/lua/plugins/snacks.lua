return {
	enabled = true,
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  dependencies = {
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup({})
    end,
  },
  opts = {
    picker = {
      enabled = true,
      sources = {
        todo_comments = { hidden = true },
      },

    },
  },
  keys = {
    -- todo comments
    { "<leader>st", function() Snacks.picker.todo_comments({ keywords = { "TODO", "HACK", "WARNING", "BUG", "NOTE", "INFO", "PERF", "ERROR" } }) end,  desc = "Todo Comment Tags" },
    { "<leader>sT", function() Snacks.picker.todo_comments() end,                                                                                      desc = "Todo" },
  },
}
