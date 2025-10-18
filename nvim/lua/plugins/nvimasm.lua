return {
  "local/vimasm", -- our local plugin
  dir = "/usr/local/vimasm/nvim",
  config = function()
    require("vimasm")
  end,
}
