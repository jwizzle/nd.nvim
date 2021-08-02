local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local actions = require('nd/telescope/actions')
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local p = {}

p.table = function (title, action, opts)
  opts = opts or {}
  local action_param = opts.action_param or {}

  local mappings = opts.mappings or function (_, map)
    map('i', '<cr>', actions.open_note)
    map('n', '<cr>', actions.open_note)

    return true
  end

  local displayer = entry_display.create({
    separator = " ",
    items = { { width = 45 }, { remaining = true } },
  })

  local make_display = function(entry)
    return displayer({ entry.value.path, entry.value.title})
  end

  local newfinder = opts.finder or finders.new_table({
    results = action(action_param),
    entry_maker = function(entry)
      return{
        value = entry,
        display = make_display,
        path = entry.path,
        ordinal = entry.path .. ' ' .. entry.title
      }
    end,
  })

  pickers.new {
    results_title = title,
    finder = newfinder,
    sorter = conf.generic_sorter({}),
    previewer = previewers.vim_buffer_cat.new({}),
    attach_mappings = mappings,
  }:find()
end

return p
