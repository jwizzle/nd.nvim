--- Expose telescope commands to neovim, which use notitiedoos actions to gather info.
local pickers = require('nd/telescope/pickers')
local actions = require('nd/telescope/actions')
local finders = require('telescope.finders')
local nd = require("nd")

local ts = {}

--- Live grep through all zettels.
ts.live_grep = function () require"telescope.builtin".live_grep{search_dirs={nd.dir}} end

--- Fuzzyfind notes.
ts.find_notes = function () pickers.table('Notitiedoos', nd.actions.list) end

--- Fuzzyfind all links to this note.
ts.find_links_to = function () pickers.table('Links to', nd.actions.links_to_note) end

--- Fuzzyfind all links from this note.
ts.find_links_from = function () pickers.table('Links from', nd.actions.links_from_note) end

--- Fuzzyfind a note, then insert a link to it underneath the cursor.
ts.insert_link = function () pickers.table('Insert link', nd.actions.list, {
    mappings = function(_, map)
      map('i', '<cr>', actions.insert_link)
      map('n', '<cr>', actions.insert_link)
      return true
    end,
  })
end

--- Fuzzyfind all tags.
ts.find_tags = function ()
  pickers.table('Tags', nd.actions.tags, {
    mappings = function(_, map)
      map('i', '<cr>', actions.open_tag)
      map('n', '<cr>', actions.open_tag)
      return true
    end,
    finder = finders.new_table(nd.actions.tags()),
  })
end

--- Fuzzyfind all tags in the current open file.
ts.find_tags_in_file = function ()
  pickers.table('Tags in file', nd.actions.tags_in, {
    mappings = function(_, map)
      map('i', '<cr>', actions.open_tag)
      map('n', '<cr>', actions.open_tag)
      return true
    end,
    finder = finders.new_table(nd.actions.tags_in()),
  })
end

return ts
