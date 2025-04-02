return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    -- add options here
    -- or leave it empty to use the default settings
  default =   {
	     -- IN MY CASE I DON'T WANT TO USE ABSOLUTE PATHS
      -- if I switch to a nother computer and I have a different username,
      -- therefore a different home directory, that's a problem because the
      -- absolute paths will be pointing to a different directory
      use_absolute_path = false, ---@type boolean

      -- make dir_path relative to current file rather than the cwd
      -- To see your current working directory run `:pwd`
      -- So if this is set to false, the image will be created in that cwd
      -- In my case, I want images to be where the file is, so I set it to true
      relative_to_current_file = true, ---@type boolean
    
       -- -- I want to save the images in a directory named after the current file,
      -- -- but I want the name of the dir to end with `-img`
      -- dir_path = function()
      --   return vim.fn.expand("%:t:r") .. "-img"
      -- end,

      -- Conditional dir_path based on skitty mode
      dir_path = vim.g.neovim_mode == "skitty" and "img" or function()
        return vim.fn.expand("%:t:r") .. "-img"
      end,
        -- -- Set the extension that the image file will have
      -- -- I'm also specifying the image options with the `process_cmd`
      -- -- Notice that I HAVE to convert the images to the desired format
      -- -- If you don't specify the output format, you won't see the size decrease

      extension = "avif", ---@type string
      process_cmd = "convert - -quality 75 avif:-", ---@type string
    }
  },
  keys = {
    -- suggested keymap
    { "<leader>P", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
  config = function ()
	  vim.keymap.set({ "n", "i" }, "<M-a>", function()
  local pasted_image = require("img-clip").paste_image()
  if pasted_image then
    -- "Update" saves only if the buffer has been modified since the last save
    vim.cmd("silent! update")
    -- Get the current line
    local line = vim.api.nvim_get_current_line()
    -- Move cursor to end of line
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], #line })
    -- I reload the file, otherwise I cannot view the image after pasted
    vim.cmd("edit!")
  end
end, { desc = "[P]Paste image from system clipboard" })
  
  end
}
