--- Expose actions to neovim.
-- Some of the telescope actions implement these to fill lists.
-- If you're looking to implement some UI around this yourself you should use these directly.
-- If you just want to zoom through your notes use the UI provided by telescope.
local nd = require("nd")
local utils = require("nd/utils")
local actions = {}

--- Jump to a link under cursor.
-- Uses vim expansion to get the current word.
-- Opens the target with :e $target
actions.jump = function ()
  local linktext = vim.fn.expand('<cWORD>')
  local filter = "'{\"link\": \"" .. linktext .. "\"}'"
  local linkedjson = utils.zettelgocmd('show --json --filter ' .. filter, nd.localbinary)

  if linkedjson ~= "" then
    vim.api.nvim_command(":e " .. linkedjson['path'])
  end
end

--- Create a new note.
actions.new = function ()
  local title = vim.fn.input('Title: ')
  if title == nil or title == '' then
    return
  end
  local filename = title:gsub(" ", "_")
  local filepath = utils.os_capture("zettelgo new " .. filename)

  if nd.open_new then vim.api.nvim_command(":e " .. filepath) end
end

--- List all notes.
-- @return table: A table/list of note objects
actions.list = function () return utils.zettelgocmd('list --json', nd.localbinary) end

--- List all tags
-- @return table: A table/list of tags
actions.tags = function () return utils.zettelgocmd('list tags --json', nd.localbinary) end

--- List all notes with a specific tag.
-- @return table: A table/list of note objects
actions.notes_with_tag = function (tag)
  local filter = "'{\"tag\": \"" .. tag .. "\"}'"
  return utils.zettelgocmd('list --json --filter ' .. filter, nd.localbinary)
end

--- List all tags in the current note.
-- @return table: List of tags
actions.tags_in = function ()
  local note = vim.fn.expand('%:t')
  local filter = "'{\"filename\": \"" .. note .. "\"}'"

  return utils.zettelgocmd('list tags --json --filter ' .. filter, nd.localbinary)
end

--- List all links to the current open note.
-- @return table: A list of notes
actions.links_to_note = function ()
  local note = vim.fn.expand('%:t')
  local filter = "'{\"linking_to\": \"" .. note .. "\"}'"

  return utils.zettelgocmd('list --json --filter ' .. filter, nd.localbinary)
end

--- List all links from the current open note to others.
-- @return table: A list of notes
actions.links_from_note = function ()
  local note = vim.fn.expand('%:t')
  local filter = "'{\"linked_from\": \"" .. note .. "\"}'"

  return utils.zettelgocmd('list --json --filter ' .. filter, nd.localbinary)
end

-- TODO Go-side
--- Sync links from the current note
-- actions.sync_links = function ()
--   print(nd.box:by_filename(vim.fn.expand('%:t')):sync_links())
-- end
-- --- Sync links of all notes
-- actions.sync_all_links = function ()
--   for _, n in pairs(nd.box.notes) do
--     print(n:sync_links())
--   end
-- end

return actions
