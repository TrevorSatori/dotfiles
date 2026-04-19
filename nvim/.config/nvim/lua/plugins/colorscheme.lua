-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
  },

  {
    "EdenEast/nightfox.nvim",
    lazy = true,
  },
}

