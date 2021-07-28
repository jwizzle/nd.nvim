local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')
local actions = require('telescope.actions')
local action_state = require'telescope.actions.state'
local nd = require('nd')

local p = {}

p.table = function (title, action, opts)
  opts = opts or {}
  local action_param = opts.action_param or {}

  local open_note = function (prompt_bufnr)
    local selection = action_state.get_selected_entry()
    local filepath = selection.value

    if not string.match(selection.value, "^/.*") then
      filepath = nd.dir .. "/" .. selection.value
    end

    actions.close(prompt_bufnr)
    vim.api.nvim_command(":e " .. filepath)
  end

  local mappings = opts.mappings or function (_, map)
    map('i', '<cr>', open_note)
    map('n', '<cr>', open_note)

    return false
  end

  pickers.new {
    results_title = title,
    finder = finders.new_table(action(action_param)),
    sorter = sorters.get_fuzzy_file(),
    previewer = previewers.vim_buffer_cat.new({}),
    attach_mappings = mappings,
  }:find()
end

return p
