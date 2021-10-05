local nd = require("nd")
local utils = require("nd/utils")
local actions = {}
require('nd/link')

actions.jump = function ()
  local link = Link:from_text(vim.fn.expand('<cWORD>'))
  vim.api.nvim_command(":e " .. link.target)
end

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

actions.gather = function ()
  nd.box:gather_async()
end

actions.list = function ()
  local t = {}
  for _, v in pairs(nd.box.notes) do
    table.insert(t, v)
  end
  return t
end

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

actions.tags_in = function ()
  local note = vim.fn.expand('%:t')

  return nd.box:by_filename(note).tags
end

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

actions.links_from_note = function ()
  local note = nd.box:by_filename(vim.fn.expand('%:t')):sync()
  local t = {}

  for _, link in ipairs(note.links) do
    table.insert(t, nd.box:by_filename(link.target))
  end

  return t
end

-- TODO Make this sync everything bidirectionally?
-- Maybe make a separate function for that
actions.sync_links = function ()
  local c_note = nd.box:by_filename(vim.fn.expand('%:t')):sync()

  for _, l in ipairs(c_note.links) do
    local target_note = nd.box:by_filename(l.target):sync()
    if not target_note:has_link(c_note) then
      target_note:add_link(Link:from_text(c_note.link))
      -- TODO Do this only once
      target_note:flush_to_file()
    end
  end
end

return actions
