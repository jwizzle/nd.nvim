local nd = require("nd")
local notes = require("nd/notes")
local utils = require("nd/utils")
local actions = {}

actions.jump = function ()
  local link = vim.fn.expand('<cWORD>')
  local filename = string.match(link, "%[%[(.-)%]%]")
  local filepath = nd.dir .. "/" .. filename

  vim.api.nvim_command(":e " .. filepath)
end

actions.new = function ()
  local title = vim.fn.input('Title: ')
  local prefix = os.date(nd.prefix) .. '_'
  local filepath = nd.dir .. "/" .. prefix .. title .. nd.suffix

  local file = assert(io.open(filepath, "w"))
  file:write(utils.interp(nd.header,  {
      date = os.date(nd.header_datestring),
      title = title,
    }))
  file:close()
  print('Created ' .. filepath)

  if nd.open_new then vim.api.nvim_command(":e " .. filepath) end
end

actions.list = function ()
  local t = {}
  for _, v in pairs(notes.box) do
    table.insert(t, v.title)
  end
  return t
end

actions.notes_with_tag = function (tag)
  local t = {}

  for k, v in pairs(notes.box) do
    for _, ntag in ipairs(v.tags) do
      if ntag == tag or ntag == '#'..tostring(tag) then
        table.insert(t, notes.box[k].title)
        break
      end
    end
  end

  return t
end

actions.tags = function ()
  local t = {}
  local list = {}

  for _, v in pairs(notes.box) do
    for _, tag in ipairs(v.tags) do
      t[tag] = true
    end
  end

  for k, _ in pairs(t) do
    table.insert(list, k)
  end

  return list
end

actions.tags_in = function ()
  local note = vim.fn.expand('%:t')

  return notes.by_filename(note).tags
end

actions.links_to_note = function ()
  local note = vim.fn.expand('%:t')
  local file_list = {}

  for _, t in pairs(notes.box) do
    for _, l in ipairs(t.links) do
      if string.find(l, " ?%[%[ ?"..note.." ?%]%] ?") then
        table.insert(file_list, t.title)
      end
    end
  end

  return file_list
end

-- TODO Make this return fancy titles for every note
actions.links_from_note = function ()
  local note = vim.fn.expand('%:t')

  return notes.by_filename(note).links
end

-- TODO
-- Eerst iets om links in te voegen
actions.sync_links = function ()
  local c_note = notes.by_filename(vim.fn.expand('%:t'))

  for _,  note in pairs(notes.box) do
    if c_note == note then print('henk') end

    ::continue::
  end
  return 'henk'
end

return actions
