return {
  "williamboman/mason.nvim",
  lazy = false,
  dependencies = {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- JS/TS formatter
        "stylua", -- Lua formatter
        "eslint_d",
	"checkstyle",
	"google-java-format", 
      },
    })
    
    -- Keymap to open Mason UI
    vim.keymap.set("n", "<leader>m", ":Mason<CR>", { desc = "Open Mason" })
  end,
}

