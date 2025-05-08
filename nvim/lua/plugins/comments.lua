return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- Safely import required modules
    local ok_comment, comment = pcall(require, "Comment")
    if not ok_comment then
      vim.notify("Comment.nvim not found!", vim.log.levels.ERROR)
      return
    end

    local ok_ts, ts_context_commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
    if not ok_ts then
      vim.notify("ts-context-commentstring not found!", vim.log.levels.WARN)
    end

    -- Setup Comment.nvim
    comment.setup({
      pre_hook = ts_context_commentstring and ts_context_commentstring.create_pre_hook() or nil,
      mappings = {
        basic = true,     -- gcc, gbc
        extra = true,     -- gco, gcO, gcA
        extended = false, -- doesn't include gb mappings
      },
    })

    -- Key mappings (normal and visual mode)
    local map = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Toggle line comment
    map("n", "<leader>,", "gcc", { remap = true, desc = "Toggle line comment" })
    map("v", "<leader>,", "gc", { remap = true, desc = "Toggle comment in selection" })

    -- Add comment above, below, or end of line
    map("n", "<leader>co", "gco", { remap = true, desc = "Comment below" })
    map("n", "<leader>cO", "gcO", { remap = true, desc = "Comment above" })
    map("n", "<leader>ca", "gcA", { remap = true, desc = "Comment at end of line" })
  end,
}

