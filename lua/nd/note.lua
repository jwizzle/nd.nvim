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

-- TODO dingon
function Note:flush_to_file()
  local handle = assert(io.open(self.path, 'r'))
  local text = handle:read "*a"; handle:close()
  local header = string.match(text, nd.note_opts.header_pattern)

  print('something to write the object back to the file.')
  print('possibly construct a new header and write that')
  print('but that would overwrite anything customized in there')
  print('possibly search for known elements like title: and only replace those')
  print('but only if found...')
  print(require('nd/json').encode(self.links))

  print(header:match("(links:.*):?"))
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
