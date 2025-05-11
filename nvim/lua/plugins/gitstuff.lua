return {
  -- Git commands in nvim (e.g. :Git)
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gh", vim.cmd.Git, { desc = "Open Fugitive" })

      local myFugitive = vim.api.nvim_create_augroup("myFugitive", {})
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = myFugitive,
        pattern = "*",
        callback = function()
          if vim.bo.ft ~= "fugitive" then return end

          local bufnr = vim.api.nvim_get_current_buf()
          local opts = { buffer = bufnr, remap = false }

          vim.keymap.set("n", "<leader>gp", function() vim.cmd.Git("pull --rebase") end, opts)
          vim.keymap.set("n", "<leader>gP", function() vim.cmd.Git("push") end, opts)
          vim.keymap.set("n", "<leader>gs", ":Git push -u origin ", opts)
        end,
      })
    end,
  },

  -- Show git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")

        -- Actions
        map("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk")
        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk")

        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gbl", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")
        map("n", "<leader>gd", gs.diffthis, "Diff This")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
      end,
    },
  },

  -- LazyGit integration (disabled by default)
  {
    "kdheepak/lazygit.nvim",
--    enabled = false,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- GitUI integration (alternative Git UI)
  {
    "brneor/gitui.nvim",
    config = function()
      vim.keymap.set("n", "<leader>gg", ":GitUi<CR>", { desc = "Open GitUI" })
    end,
  },

{
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",         -- Required
    "sindrets/diffview.nvim",        -- Optional - Diff integration

    -- Optional pickers (choose only one if needed)
    "nvim-telescope/telescope.nvim",
    -- "ibhagwan/fzf-lua",
    -- "echasnovski/mini.pick",
    -- "folke/snacks.nvim",
  },
  config = function()
    local neogit = require("neogit")
    neogit.setup({
      kind = "floating",  -- Open in a floating window
      -- Optional: Customize floating window appearance
      -- remember to adjust layout if needed
      integrations = {
        diffview = true,  -- Enable if using diffview.nvim
        telescope = true, -- Enable if using telescope.nvim
      },
    })

    -- Key mapping to open Neogit
    vim.keymap.set("n", "<leader>gn", function()
      neogit.open()
    end, { desc = "Open Neogit (Floating)" })
  end
},

}

