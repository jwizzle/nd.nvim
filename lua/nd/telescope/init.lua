local pickers = require('nd/telescope/pickers')
local actions = require('nd/telescope/actions')
local nd = require("nd")

local ts = {}

ts.live_grep = function () require"telescope.builtin".live_grep{search_dirs={nd.dir}} end

ts.find_notes = function () pickers.table('Notitiedoos', nd.actions.list) end

ts.find_links_to = function () pickers.table('Links to', nd.actions.links_to_note) end

ts.find_links_from = function () pickers.table('Links from', nd.actions.links_from_note) end

ts.find_tags = function ()
  pickers.table('Tags', nd.actions.tags, {
    mappings = function(_, map)
      map('i', '<cr>', actions.open_tag)
      map('n', '<cr>', actions.open_tag)
      return true
    end
  })
end

ts.find_tags_in_file = function ()
  pickers.table('Tags in file', nd.actions.tags_in, {
    mappings = function(_, map)
      map('i', '<cr>', actions.open_tag)
      map('n', '<cr>', actions.open_tag)
      return true
    end
  })
end

return ts
