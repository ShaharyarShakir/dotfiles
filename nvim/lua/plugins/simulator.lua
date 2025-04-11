
return {
  "dimaportenko/telescope-simulators.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("simulators").setup({
      android_emulator = true,
      apple_simulator = false, -- Set to true if on macOS and need iOS
    })

    require("telescope").load_extension("simulators")
    vim.keymap.set("n", "<leader>er", "<cmd>Telescope simulators run<CR>", { desc = "Run Android Emulator" })

  end,
  cmd = { "Telescope simulators" },
  event = "VeryLazy",
}
