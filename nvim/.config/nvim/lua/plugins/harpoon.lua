-- ~/.config/nvim/lua/plugins/harpoon.lua
return {
  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({
        settings = {
          save_on_toggle   = true,
          sync_on_ui_close = false,
        },
      })

      local list = harpoon:list()

      -- Add current file
      vim.keymap.set("n", "<leader>ha", function()
        list:add()
      end, { desc = "Harpoon: Add file" })

      -- Toggle menu
      vim.keymap.set("n", "<leader>hh", function()
        harpoon.ui:toggle_quick_menu(list)
      end, { desc = "Harpoon: Toggle menu" })

      -- Next / Prev
      vim.keymap.set("n", "<leader>hn", function()
        list:next()
      end, { desc = "Harpoon: Next file" })
      vim.keymap.set("n", "<leader>hp", function()
        list:prev()
      end, { desc = "Harpoon: Prev file" })

      -- Remove current file
      vim.keymap.set("n", "<leader>hr", function()
        list:remove()
        harpoon:sync()
      end, { desc = "Harpoon: Remove current file" })

      -- Clear all marks
      vim.keymap.set("n", "<leader>hc", function()
        list:clear()
        harpoon:sync()
      end, { desc = "Harpoon: Clear all marks" })
    end,
  },
}

