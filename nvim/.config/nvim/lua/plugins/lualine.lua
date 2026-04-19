
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Highlight groups
    vim.api.nvim_set_hl(0, "LualineFilenameBlock", { fg = "#cdd6f4", bg = "#313244", bold = true })
    vim.api.nvim_set_hl(0, "LualineDiagnosticsError", { fg = "#f38ba8", bold = true })
    vim.api.nvim_set_hl(0, "LualineDiagnosticsWarn", { fg = "#f9e2af", bold = true })
    vim.api.nvim_set_hl(0, "LualineFolder", { fg = "#fab387", bg = "NONE", bold = true })

    -- Diagnostic icons
    local function lsp_diagnostics()
      local diagnostics = vim.diagnostic.get(0)
      local counts = { error = 0, warn = 0 }

      for _, d in ipairs(diagnostics) do
        if d.severity == vim.diagnostic.severity.ERROR then
          counts.error = counts.error + 1
        elseif d.severity == vim.diagnostic.severity.WARN then
          counts.warn = counts.warn + 1
        end
      end

      local result = {}
      if counts.error > 0 then
        table.insert(result, "%#LualineDiagnosticsError# " .. counts.error)
      end
      if counts.warn > 0 then
        table.insert(result, "%#LualineDiagnosticsWarn# " .. counts.warn)
      end
      return table.concat(result, " ")
    end

    -- Styled filename block (boxed, no red oval)
    local function styled_filename()
      local filename = vim.fn.expand("%:t")
      if filename == "" then return "" end
      local icon, _ = require("nvim-web-devicons").get_icon(filename, nil, { default = true })
      return "%#LualineFilenameBlock# " .. icon .. " " .. filename .. " %#Normal#"
    end

    -- Get parent folder of current file
    local function file_folder()
      local path = vim.fn.expand("%:p:h:t")
      return "📁 " .. path
    end

    require("lualine").setup({
      options = {
        theme = "auto",
        icons_enabled = true,
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = "",
            color = { fg = "#1e1e2e", bg = "#89b4fa", gui = "bold" },
          },
        },
        lualine_b = {
          styled_filename,
          { "branch", icon = "", color = { fg = "#f5c2e7" } },
        },
        lualine_c = {},
        lualine_x = {
          { lsp_diagnostics },
          { file_folder, color = "LualineFolder" },
          {
            "filetype",
            icon_only = true,
            color = { fg = "#94e2d5" },
          },
        },
        lualine_y = {
          { "progress", color = { fg = "#f9e2af" } },
        },
        lualine_z = {
          { "location", color = { fg = "#a6e3a1", gui = "bold" } },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    })
  end,
}
