return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- Optional: disable default mappings if you want custom ones
    vim.g.VM_default_mappings = 1
    -- You can tweak more options here
    vim.g.VM_maps = {
      ["Find Under"]         = "<C-n>",
      ["Find Subword Under"] = "<C-n>",
      ["Select All"]         = "g<C-n>",
      ["Skip Region"]        = "<C-x>",
      ["Remove Region"]      = "<C-p>",
    }
  end,
  lazy = false, -- Load immediately, or set to true if you want to lazy load
}

