return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },

  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local util = require("lspconfig.util")

    -- ======================
    -- Diagnostics signs
    -- ======================
    local signs = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "󰠠",
      [vim.diagnostic.severity.INFO]  = "",
    }
    vim.diagnostic.config({
      signs = { text = signs },
      virtual_text = true,
      underline = true,
      update_in_insert = false,
    })

    -- ======================
    -- LSP Keymaps
    -- ======================
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }
        local map = vim.keymap.set

        map("n", "gR", "<cmd>Telescope lsp_references<CR>", { desc = "LSP references", buffer = ev.buf })
        map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = ev.buf })
        map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "LSP definitions", buffer = ev.buf })
        map("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "LSP implementations", buffer = ev.buf })
        map("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "LSP type definitions", buffer = ev.buf })
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions", buffer = ev.buf })
        map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = ev.buf })
        map("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Buffer diagnostics", buffer = ev.buf })
        map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = ev.buf })
        map("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = ev.buf })
        map("i", "<C-h>", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = ev.buf })
        map("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", buffer = ev.buf })
      end,
    })

    -- ======================
    -- LSP server configs
    -- ======================
    local servers = {
      ts_ls = { root_dir = util.root_pattern("package.json", "tsconfig.json", ".git") },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.stdpath("config") .. "/lua"] = true,
              },
            },
          },
        },
      },
      tailwindcss = { root_dir = util.root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json", ".git") },
      terraformls = { root_dir = util.root_pattern("main.tf", ".git") },
      svelte = {},
      graphql = {},
      html = {},
      cssls = {},
      bashls = {},
      pyright = {},
      emmet_ls = {},
    }

    -- ======================
    -- Enable all servers
    -- ======================
    for name, cfg in pairs(servers) do
      cfg.capabilities = capabilities
      vim.lsp.config(name, cfg)   -- define/override server config
      vim.lsp.enable(name)        -- activate server
    end
  end,
}
