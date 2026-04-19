return {
  {
    "goolord/alpha-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    init = function()
      -- disable Neovim's built-in splash
      vim.opt.shortmess:append("I")
    end,

    config = function()
      local alpha     = require("alpha")
      local dash      = require("alpha.themes.dashboard")

      --------------------------------------------------------------------------------
      -- 1) Your FIGlet “NEOVIM” header (no manual padding!)
      --------------------------------------------------------------------------------
      dash.section.header.val = {
        "",  -- top padding
        " ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        " ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        " ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        " ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        " ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        " ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "",  -- bottom padding
      }
      dash.section.header.opts = {
        position = "center",
        hl       = "Function",
      }

      --------------------------------------------------------------------------------
      -- 2) NC-style menu buttons (already centered by default)
      --------------------------------------------------------------------------------
      dash.section.buttons.val = {
        dash.button("f", "  Find File",    ":Telescope find_files<CR>"),
        dash.button("o", "  Recent Files", ":Telescope oldfiles<CR>"),
        dash.button("w", "  Find Word",     ":Telescope live_grep<CR>"),
        dash.button("t", "  Themes",       ":Telescope themes<CR>"),
        dash.button("h", "  Mappings",     ":Telescope keymaps<CR>"),
        dash.button("q", "  Quit NVIM",    ":qa<CR>"),
      }
      dash.section.buttons.opts = {
        position = "center",
        hl       = "Identifier",
      }

      -- push everything down a bit
      dash.opts.layout[1].val = 5

      -- finally, fire it up
      alpha.setup(dash.config)
    end,
  },
}
