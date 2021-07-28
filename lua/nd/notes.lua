local utils = require('nd/utils')

local notes = {
  box = {},
  files = {},
}

notes.gather = function ()
  local output = utils.os_capture('find '..notes.dir.." -type f -not -path '*/\\.git/*'")
  for filename in string.gmatch(output, "/%g+" .. notes.suffix) do
    table.insert(notes.files, filename)
  end
end

notes.tags_from_header = function(header)
  local t = {}
  for i in string.gmatch(header, notes.tag_pattern) do
    table.insert(t, i)
  end
  return t
end

notes.links_from_header = function(header)
  local t = {}
  for name, link in string.gmatch(header, notes.link_pattern) do
    if not link then
      -- This is actually the link in these cases
      table.insert(t, name)
    else
      t[name] = link
    end
  end
  return t
end

notes.extract_one = function(path)
  local file = assert(io.open(path, 'r'))
  local text = file:read "*a"; file:close()
  local header = string.match(text, notes.header_pattern)

  local title = string.match(header, notes.title_pattern)
  local date = string.match(header, notes.date_pattern)
  local tags = notes.tags_from_header(header)
  local links = notes.links_from_header(header)

  notes.box[title] = {
    tags = tags,
    date = date,
    title = title,
    links = links,
    path = path,
  }
end

notes.to_box = function ()
  for _, file in ipairs(notes.files) do
    notes.extract_one(file)
  end
end

notes.by_title = function (title)
  local result = {}

  for _, note in pairs(notes.box) do
    if note.title == title then
      result = note
    end
  end

  return result
end

notes.by_filename = function (filename)
  local result = {}

  for _, note in pairs(notes.box) do
    if string.find(note.path, filename) then
      result = note
    end
  end

  return result
end

notes.setup = function (opts)
  opts = opts or {}
  for k, v in pairs(opts) do notes[k] = v end

  notes.gather()
  notes.to_box()
end

return notes
