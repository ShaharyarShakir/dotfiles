return {
  "nvimdev/dashboard-nvim",
  enabled = false,
  cmd = "Dashboard",  -- Load when :Dashboard command is used
  event = "VimEnter", -- Load on startup
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local logo = [[
                                                     
         ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ 
         ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ 
         ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ 
         ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ 
         ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ 
         ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ 
                                                            
    ]]
    logo = string.rep("\n", 8) .. logo .. "\n\n"

    local opts = {
      theme = "doom",
      hide = {
        statusline = false, -- Keep statusline enabled
      },
      config = {
        header = vim.split(logo, "\n"),
        center = {
          { action = "Telescope find_files", desc = " Find File", icon = " ", key = "f" },
          { action = "ene | startinsert", desc = " New File", icon = " ", key = "n" },
          { action = "Telescope oldfiles", desc = " Recent Files", icon = " ", key = "r" },
          { action = "Telescope live_grep", desc = " Find Text", icon = " ", key = "g" },
          { action = "edit $MYVIMRC", desc = " Config", icon = " ", key = "c" },
          { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
          { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
          { action = "qa", desc = " Quit", icon = " ", key = "q" },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    -- Adjust description alignment
    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- Auto-reopen dashboard after Lazy.nvim is closed
    if vim.o.filetype == "lazy" then
      vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(vim.api.nvim_get_current_win()),
        once = true,
        callback = function()
          vim.schedule(function()
            vim.cmd("Dashboard")
          end)
        end,
      })
    end

    return opts
  end,
}
