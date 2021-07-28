local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local previewers = require('telescope.previewers')

local p = {}

p.table = function (title, action, opts)
  opts = opts or {}
  local action_param = opts.action_param or {}
  local mappings = opts.mappings or function () return true end

  pickers.new {
    results_title = title,
    finder = finders.new_table(action(action_param)),
    sorter = sorters.get_fuzzy_file(),
    previewer = previewers.vim_buffer_cat.new({}),
    attach_mappings = mappings,
  }:find()
end

return p
