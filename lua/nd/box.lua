local utils = require('nd/utils')

local notes = {
  box = {},
  files = {},
}

notes.gather = function ()
  local output = utils.os_capture('find '..notes.dir.." -type f -not -path '*/\\.git/*'")
  for filename in string.gmatch(output, "/%g+" .. notes.suffix) do
    local newnote = Note:from_path(filename)
    notes.box[newnote.title] = newnote
  end
end

notes.by_link = function (link)
  local result = {}
  local filename = link:gsub("%[", ''):gsub("%]", '')

  for _, note in pairs(notes.box) do
    if note.path:find(filename) then
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

  require('nd/note')
  notes.gather()
end

return notes
