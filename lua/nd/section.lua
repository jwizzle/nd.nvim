-- TODO Finish
local nd = require('nd')
require('nd/link')

Section = {
  title = '',
  text = '',
  content = '',
}

function Section:sync()
  local newnote = Section:from_path(self.path)

  nd.box.notes[self.title] = newnote

  return newnote
end

function Section:add_link(link) table.insert(self.links, link) end

function Section:new (opts)
  opts = opts or {}

  setmetatable(opts, self)
  self.__index = self

  return opts
end

function Section:from_header(header)
  local newsection = self:new({
    title = string.match(header, nd.note_opts.title_pattern),
    text = '',
    content = '',
  })
  return newsection
end
