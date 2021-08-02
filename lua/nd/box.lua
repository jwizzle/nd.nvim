require('nd/note')

local utils = require('nd/utils')
local nd = require('nd')

Box = {
  notes = {}
}

function Box:gather ()
  local output = utils.os_capture('find '..nd.dir.." -type f -not -path '*/\\.git/*'")
  for filename in string.gmatch(output, "/%g+" .. nd.suffix) do
    local newnote = Note:from_path(filename)
    self.notes[newnote.title] = newnote
  end
end

function Box:by_link (link)
  local result = {}
  local filename = link:gsub("%[", ''):gsub("%]", '')

  for _, note in pairs(self) do
    if note.path:find(filename) then
      result = note
    end
  end

  return result
end

function Box:by_filename (filename)
  local result = {}

  for _, note in pairs(self) do
    if string.find(note.path, filename) then
      result = note
    end
  end

  return result
end

function Box:setup (opts)
  opts = opts or {}
  for k, v in pairs(opts) do self[k] = v end

  self:gather()

  return self
end
