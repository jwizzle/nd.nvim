--- A note object, representing a file on your system in memory.
local nd = require('nd')
require('nd/link')
require('nd/section')

Note = {
  tags = {},
  date = '',
  title = '',
  links = {},
  path = '',
  link = '',
  sections = {}
}

--- Sync the note.
-- Creates a new note from it's current path and replaces the object.
-- @return Note: The new note
function Note:sync()
  local newnote = Note:from_path(self.path)

  nd.box.notes[self.title] = newnote

  return newnote
end

--- Add a link to the note.
-- @param link Link: A link object
function Note:add_link(link) table.insert(self.links, link) end

--- Flush the note to it's file.
-- Only operates on the header.
-- Might make some assumptions about how you want your notes to look.
function Note:flush_to_file()
  local handle = assert(io.open(self.path, 'r'))
  local text = handle:read "*a"; handle:close()

  local process_changes = function(obj_in_mem, file_content)
    local new_rows = {}

    for _, l in ipairs(obj_in_mem) do
      local obj_text = l.text or l
      if not file_content:find(obj_text, 1, true) then
        table.insert(new_rows, l)
      end
    end

    return new_rows
  end
  local write_changes = function(updated_mem_object, current_content)
    local newcontent = current_content

    for _, l in ipairs(updated_mem_object) do
      local target_note = nd.box:by_filename(l.target)
      newcontent = newcontent .. "\t- " .. target_note.title .. ": " .. l.text
    end
    local write_handle = assert(io.open(self.path, 'w'))
    write_handle:write(text:gsub(current_content:gsub("([^%w])", "%%%1"):sub(1, -3), newcontent):sub(1, -2))
    write_handle:close()
  end

  for title, section in pairs(self.sections) do
    if self[title] == nil then goto continue end

    local content = section.content
    local newlinks = process_changes(self[title], content)

    if next(newlinks) == nil then goto continue end

    write_changes(newlinks, content)
    ::continue::
  end
end

--- Check if the current note has a link to another one.
-- @param note Note: The note to check
-- @return bool: Do we have a link to the other note?
function Note:has_link(note)
  local b = false
  for _, l in pairs(self.links) do
    if l.target == note.path then
      b = true
      break
    end
  end
  return b
end

--- Sync links between notes.
-- Checks if all notes linked from this one have a backlink.
-- If not create them and write the file.
-- @return string: Output to show the user
function Note:sync_links()
  local output = ''
  self:sync()

  local function process_links(l)
    local notestatus, target_note = pcall(nd.box.by_filename, nd.box, l.target)
    if notestatus and next(target_note) then
      target_note:sync()
    else
      error("File behind link not found: " .. l.text)
    end
    local changes = false

    if not target_note:has_link(self) then
      target_note:add_link(Link:from_text(self.link))
      changes = true
    end

    if changes then
      local status, message = pcall(Note.flush_to_file, target_note)
      if not status then
        error("Error flushing to file: " .. message)
      end
    end

    return changes
  end

  for _, l in ipairs(self.links) do
    local success, changes = pcall(process_links, l)
    if success and changes then
      output = output .. "Wrote to " .. l.target
    elseif not success then
      output = output .. "Error processling links for " .. l.text .. ": " .. changes
    end
  end

  return output
end

--- Instantiate a new note.
-- @param opts table: A table of options
-- @return table: The new Note object
function Note:new (opts)
  opts = opts or {}

  setmetatable(opts, self)
  self.__index = self

  return opts
end

--- Read a file, and create a note in memory.
-- @param path string: The path to the file
-- @return Note: The new note object
function Note:from_path(path)
  local file = assert(io.open(path, 'r'))
  local text = file:read "*a"; file:close()
  local header = string.match(text, nd.note_opts.header_pattern)
  if not header then return error('Unable to parse header for' .. path) end
  local _, sections = pcall(Section.all_from_header, Section, header)

  local tags_from_header = function()
    local t = {}
    for i in string.gmatch(header, nd.note_opts.tag_pattern) do
      table.insert(t, i)
    end
    return t
  end
  local links_from_header = function()
    local t = {}
    for link in string.gmatch(header, nd.note_opts.link_pattern) do
      table.insert(t, Link:from_text(link))
    end
    return t
  end

  local newnote = self:new({
    title = string.match(header, nd.note_opts.title_pattern),
    date = string.match(header, nd.note_opts.date_pattern),
    tags = tags_from_header(),
    links = links_from_header(),
    link = "[["..string.match(path, "[/%g+]+/(%g+)$").."]]",
    path = path,
    sections = sections,
  })
  return newnote
end
