return {
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = { "GrugFar", "GrugFarWithin" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Project-wide)",
      },
      {
        "<leader>sR",
        function()
          require("grug-far").open({
            prefills = {
              paths = vim.fn.expand("%"), -- Scope to the current file only
            },
            within = true,  -- Ensure it's scoped to the current file
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace (Current File Only)",
      },
    },
  },
}

