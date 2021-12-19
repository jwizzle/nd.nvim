--- Expose actions to neovim.
-- Some of the telescope actions implement these to fill lists.
-- If you're looking to implement some UI around this yourself you should use these directly.
-- If you just want to zoom through your notes use the UI provided by telescope.
local nd = require("nd")
local utils = require("nd/utils")
local actions = {}
require('nd/link')

--- Jump to a link under cursor.
-- Uses vim expansion to get the current word.
-- Opens the target with :e $target
actions.jump = function ()
  local link = Link:from_text(vim.fn.expand('<cWORD>'))
  vim.api.nvim_command(":e " .. link.target)
end

--- Create a new note.
-- Asks for a title, uses the template in settings for initial content.
actions.new = function ()
  local title = vim.fn.input('Title: ')
  if title == nil or title == '' then
    return
  end
  local filename = title:gsub(" ", "_")
  local prefix = os.date(nd.prefix) .. '_'
  local filepath = nd.dir .. "/" .. prefix .. filename .. nd.suffix

  local file = assert(io.open(filepath, "w"))
  file:write(utils.interp(nd.header,  {
      date = os.date(nd.header_datestring),
      title = title,
    }))
  file:close()
  print('Created ' .. filepath)
  nd.box:gather_async()

  if nd.open_new then vim.api.nvim_command(":e " .. filepath) end
end

--- Force gathering of notes asynchronously.
actions.gather = function ()
  nd.box:gather_async()
end

--- List all notes.
-- @return table: A table/list of note objects
actions.list = function ()
  local t = {}
  for _, v in pairs(nd.box.notes) do
    table.insert(t, v)
  end
  return t
end

--- List all notes with a specific tag.
-- @return table: A table/list of note objects
actions.notes_with_tag = function (tag)
  local t = {}

  for k, v in pairs(nd.box.notes) do
    for _, ntag in ipairs(v.tags) do
      if ntag == tag or ntag == '#'..tostring(tag) then
        table.insert(t, nd.box.notes[k])
        break
      end
    end
  end

  return t
end

--- List all tags
-- @return table: A table/list of tags
actions.tags = function ()
  local t = {}
  local list = {}

  for _, v in pairs(nd.box.notes) do
    for _, tag in ipairs(v.tags) do
      t[tag] = true
    end
  end

  for k, _ in pairs(t) do
    table.insert(list, k)
  end

  return list
end

--- List all tags in the current note.
-- @return table: List of tags
actions.tags_in = function ()
  local note = vim.fn.expand('%:t')

  return nd.box:by_filename(note).tags
end

--- List all links to the current open note.
-- Also syncs the notes, just to be sure.
-- @return table: List of notes
actions.links_to_note = function ()
  local note = nd.box:by_filename(vim.fn.expand('%:t')):sync()
  local file_list = {}

  for _, t in pairs(nd.box.notes) do
    for _, l in ipairs(t.links) do
      if l.target == note.path then
        t:sync()
        table.insert(file_list, t)
      end
    end
  end

  return file_list
end

--- List all links from the current open note to others.
-- @return table: A list of notes
actions.links_from_note = function ()
  local note = nd.box:by_filename(vim.fn.expand('%:t')):sync()
  local t = {}

  for _, link in ipairs(note.links) do
    table.insert(t, nd.box:by_filename(link.target))
  end

  return t
end

--- Sync links from the current note
actions.sync_links = function ()
  print(nd.box:by_filename(vim.fn.expand('%:t')):sync_links())
end

--- Sync links of all notes
actions.sync_all_links = function ()
  for _, n in pairs(nd.box.notes) do
    print(n:sync_links())
  end
end

return actions
