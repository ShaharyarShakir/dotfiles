return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")
    notify.setup({
      -- Customize your notify settings here
      stages = "fade_in_slide_out",
      timeout = 3000,
      background_colour = "#000000",
    })
    vim.notify = notify
  end,
}

