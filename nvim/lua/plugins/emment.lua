return {
  "olrtg/nvim-emmet",
  config = function()
    local emmet = require("nvim-emmet")

    local function safe_wrap()
      local ft = vim.bo.filetype

      if ft == "svelte" then
        -- Temporarily override Treesitter parser for this buffer
        vim.treesitter.stop()
        vim.treesitter.language.register('html', 'svelte')
      end

      -- Schedule so the Treesitter change takes effect before Emmet runs
      vim.schedule(function()
        emmet.wrap_with_abbreviation()

        -- Restore original parser afterwards
        if ft == "svelte" then
          vim.schedule(function()
            -- Restart Treesitter with correct parser
            vim.treesitter.stop()
            vim.cmd("set filetype=svelte")
          end)
        end
      end)
    end

    vim.keymap.set({ "n", "v" }, "<leader>xe", safe_wrap,
      { desc = "Emmet wrap with abbreviation (safe)" })
  end,
}

