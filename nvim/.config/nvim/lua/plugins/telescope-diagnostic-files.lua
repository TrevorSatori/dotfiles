local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")

local function get_files_with_errors()
  local diagnostics = vim.diagnostic.get(nil, {
    severity = vim.diagnostic.severity.ERROR,
  })

  local file_set = {}
  for _, diag in ipairs(diagnostics) do
    local bufname = vim.api.nvim_buf_get_name(diag.bufnr)
    file_set[bufname] = true
  end

  local files = {}
  for file in pairs(file_set) do
    table.insert(files, file)
  end

  return files
end

local function pick_error_files()
  local files = get_files_with_errors()

  pickers.new({}, {
    prompt_title = "Files with Errors",
    finder = finders.new_table {
      results = files,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
          filename = entry,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      require("telescope.actions").select_default:replace(function(_, _)
        local entry = require("telescope.actions.state").get_selected_entry()
        vim.cmd("edit " .. entry.value)
      end)
      return true
    end,
  }):find()
end

return {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fe",
      pick_error_files,
      desc = "Telescope: Files with Errors",
    },
  },
}

