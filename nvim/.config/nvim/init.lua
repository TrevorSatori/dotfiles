if vim.g.vscode then 
  require "user.vscode_keymaps" 
else 
  require("config.lazy")
end


-- uniform tabs
vim.opt.softtabstop= 0
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- Convert tabs to spaces


-- Format Code
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format() end, { desc = "Format buffer" })

-- Line Numbers
vim.opt.number = true           -- Shows absolute line numbers
vim.opt.relativenumber = true  -- Shows relative numbers (optional but common)

-- Yank / paste  to system clipboard in normal and visual mode
vim.opt.clipboard = "unnamedplus"

-- Go to definition
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap=true, silent=true })

-- swap panes
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

vim.keymap.set("n", "<C-d>", "<C-d>zz", {noremap = true})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {noremap = true})
vim.keymap.set("n", "n",     "nzzzv",    {noremap = true})
vim.keymap.set("n", "N",     "Nzzzv",    {noremap = true})

-- Background removal

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "VertSplit", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
