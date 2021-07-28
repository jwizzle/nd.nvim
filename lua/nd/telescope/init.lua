local actions = require('telescope.actions')
local action_state = require'telescope.actions.state'
local pickers = require('nd/telescope/pickers')
local nd = require("nd")

local ts = {}

ts.open_tag = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  pickers.table(selection.value, nd.actions.notes_with_tag, {action_param = selection.value})
end

ts.live_grep = function () require"telescope.builtin".live_grep{search_dirs={nd.dir}} end

ts.find_notes = function () pickers.table('Notitiedoos', nd.actions.list) end

ts.find_links_to = function () pickers.table('Links to', nd.actions.links_to_note) end

ts.find_links_from = function () pickers.table('Links from', nd.actions.links_from_note) end

ts.find_tags = function ()
  pickers.table('Tags', nd.actions.tags, {
    mappings = function(_, map)
      map('i', '<cr>', ts.open_tag)
      map('n', '<cr>', ts.open_tag)
      return true
    end
  })
end

ts.find_tags_in_file = function ()
  pickers.table('Tags in file', nd.actions.tags_in, {
    mappings = function(_, map)
      map('i', '<cr>', ts.open_tag)
      map('n', '<cr>', ts.open_tag)
      return true
    end
  })
end

return ts
