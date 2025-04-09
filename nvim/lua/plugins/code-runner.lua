return {
  "CRAG666/code_runner.nvim",
  lazy = true,
  config = function()
    require("code_runner").setup({
      mode = "float", -- Show output in floating terminal
      startinsert = true,
      filetype = {
        python = "python3 -u",
        cpp = "g++ $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
        c = "gcc $fileName -o $fileNameWithoutExt && ./$fileNameWithoutExt",
        java = "javac $fileName && java $fileNameWithoutExt",
        javascript = "node",
        typescript = "ts-node",
        rust = "cargo run",
        go = "go run",
        sh = "bash",
      },
      project = {
        -- Optional: Add custom projects here
      },
    })

    vim.keymap.set("n", "<leader>rr", ":RunCode<CR>", { noremap = true, silent = false, desc = "Run Last Code" })
    vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false, desc = "Run Current File" })
    vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false, desc = "Run File in Tab" })
    vim.keymap.set("n", "<leader>rp", ":RunProject<CR>", { noremap = true, silent = false, desc = "Run Project" })
    vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false, desc = "Close Runner" })
    vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false, desc = "Show Filetype Command" })
    vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false, desc = "Show Projects List" })
  end,
}

