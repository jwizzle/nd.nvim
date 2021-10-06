local nd = require('nd')
require('nd/link')

Note = {
  tags = {},
  date = '',
  title = '',
  links = {},
  path = '',
  link = '',
}

function Note:sync()
  local newnote = Note:from_path(self.path)

  nd.box.notes[self.title] = newnote

  return newnote
end

function Note:add_link(link) table.insert(self.links, link) end

-- TODO Split this up, flushing should be more than links only but the only usecase for now
-- Maybe something like section regexes for headers. Making a header { section: text } kind of structure
-- an integral part of notes.
-- Can probably wait until this function is touched again.
function Note:flush_to_file()
  local handle = assert(io.open(self.path, 'r'))
  local text = handle:read "*a"; handle:close()
  local header = string.match(text, nd.note_opts.header_pattern)

  local linksection = header:match("(links:.*):?")
  local newlinksection = linksection
  local newlinks = {}
  for _, l in ipairs(self.links) do
    if not linksection:find(l.text, 1, true) then
      table.insert(newlinks, l)
    end
  end
  for _, l in ipairs(newlinks) do
    newlinksection = newlinksection .. "\t- " .. l.text
  end

  local write_handle = assert(io.open(self.path, 'w'))
  write_handle:write(text:gsub(linksection:gsub("([^%w])", "%%%1"):sub(1, -3), newlinksection):sub(1, -2))
  write_handle:close()
end

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

-- TODO test this with different header set-ups. It's only tested on my specific headers now.
function Note:sync_links()
  local output = ''
  self:sync()

  local function process_links(l)
    local target_note = nd.box:by_filename(l.target):sync()
    local changes = false

    if not target_note:has_link(self) then
      target_note:add_link(Link:from_text(self.link))
      changes = true
    end

    if changes then
      target_note:flush_to_file()
    end

    return changes
  end

  for _, l in ipairs(self.links) do
    local success, changes = pcall(process_links, l)
    if success and changes then
      output = output .. "Wrote to " .. l.target
    end
  end

  return output
end

-- TODO Why does this exist? outside of note creation?
function Note:parse_links()
  for i, l in ipairs(self.links) do
    self.links[i] = Link:from_text(l)
  end
end

function Note:new (opts)
  opts = opts or {}

  setmetatable(opts, self)
  self.__index = self

  return opts
end

function Note:from_path(path)
  local file = assert(io.open(path, 'r'))
  local text = file:read "*a"; file:close()
  local header = string.match(text, nd.note_opts.header_pattern)
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
      table.insert(t, link)
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
  })
  newnote:parse_links()
  return newnote
end
