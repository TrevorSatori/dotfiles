return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
      { "artemave/workspace-diagnostics.nvim" },
    },
    config = function()
      local util = require("lspconfig.util")
      local wsdiag = require("workspace-diagnostics")
      local mason_path = vim.fn.stdpath("data") .. "/mason/bin/"

      -- Workspace diagnostics
      wsdiag.setup({
        workspace_files = function()
          local all = vim.fn.systemlist("git ls-files")
          return vim.tbl_filter(function(f)
            return not f:match("^db/ent/")
          end, all)
        end,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          wsdiag.populate_workspace_diagnostics(client, args.buf)
        end,
      })

      -- Mason setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "ts_ls", "pyright" },
        automatic_installation = true,
      })

      -- Diagnostic UI
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
      vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show all diagnostics" })

      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, { focus = false })
        end,
      })

      vim.opt.updatetime = 1000

      -- ===== LSP Servers =====
      local function start_server(name, cmd, root_dir, extra_opts)
        vim.lsp.start(vim.tbl_deep_extend("force", {
          name = name,
          cmd = cmd,
          root_dir = root_dir,
        }, extra_opts or {}))
      end

      -- Go
      start_server(
        "gopls",
        { mason_path .. "gopls" },
        util.root_pattern("go.work", "go.mod", ".git"),
        {
          settings = {
            gopls = {
              analyses = { unusedparams = true, ST1000 = false },
              staticcheck = true,
            },
          },
        }
      )


      -- TypeScript/JavaScript
      start_server(
        "ts_ls",
        { mason_path .. "typescript-language-server", "--stdio" },
        util.root_pattern("package.json", "tsconfig.json", ".git")
      )

      -- Python
      start_server(
        "pyright",
        { mason_path .. "pyright-langserver", "--stdio" },
        util.root_pattern("pyproject.toml", "setup.py", "requirements.txt", ".git")
      )
    end,
  },
}

