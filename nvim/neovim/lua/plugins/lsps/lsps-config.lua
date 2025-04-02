return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- Autocompletion
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local lspconfig = require("lspconfig")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Keybind function for LSP
    local function set_lsp_keymaps(bufnr)
      local opts = { buffer = bufnr, silent = true }
      local keymap = vim.keymap.set

      keymap("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
      keymap("n", "gD", vim.lsp.buf.declaration, opts)
      keymap("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
      keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
      keymap("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
      keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
      keymap("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
      keymap("n", "<leader>d", vim.diagnostic.open_float, opts)
      keymap("n", "[d", vim.diagnostic.goto_prev, opts)
      keymap("n", "]d", vim.diagnostic.goto_next, opts)
      keymap("n", "K", vim.lsp.buf.hover, opts)
      keymap("n", "<leader>rs", ":LspRestart<CR>", opts)
    end

    -- Automatically attach keybinds on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        set_lsp_keymaps(ev.buf)
      end,
    })

    -- Diagnostic symbols
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Setup LSP servers
    local servers = {
      ts_ls = {},
      html = {},
      cssls = {},
      tailwindcss = {},
      svelte = {
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = { "*.js", "*.ts" },
            callback = function(ctx)
              client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
            end,
          })
        end,
      },
      graphql = { filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" } },
      emmet_ls = { filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" } },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            completion = { callSnippet = "Replace" },
          },
        },
      },
    }

    -- Apply LSP settings
    for server, config in pairs(servers) do
      config.capabilities = capabilities
      lspconfig[server].setup(config)
    end
  end,
}

