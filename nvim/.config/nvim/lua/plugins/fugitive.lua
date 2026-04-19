return {
  "tpope/vim-fugitive",
  lazy = false, -- load immediately or set to true to load lazily
  event = { "BufReadPre", "BufNewFile" }, -- optional: if lazy loading
  config = function()
    -- optional: any custom keymaps or settings
    vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
  end,
}

