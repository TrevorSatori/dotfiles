-- in your telescope.nvim plugin spec
return {
  "nvim-telescope/telescope.nvim",
  keys = function()
    return {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep({
            prompt_title = "🔍 Live Grep",
            -- you can add extra ripgrep args here if you like
          })
        end,
        desc = "Fuzzy find (live grep) in repo",
      },
      {
        "<leader>fd",
        function()
          require("telescope.builtin").diagnostics({
            workspace_diagnostics = true, -- ← show errors from every buffer
          })
        end,
        desc = "Workspace Diagnostics",
      },
    }
  end,
}
