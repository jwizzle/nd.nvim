--- Represent a section in the header of a note.
-- This makes some assumptions about how you use titles in headers.
require('nd/link')

Section = {
  title = '',
  text = '',
  content = '',
}

--- Instantiate a new section.
-- @param opts table: A table of options
-- @return Section: A new section object
function Section:new (opts)
  opts = opts or {}

  setmetatable(opts, self)
  self.__index = self

  return opts
end

--- Create a new section from a title and the total header.
-- @param title string: The title of the section to extract
-- @param header string: The header to extract from
-- @return Section: A new section object
function Section:from_header(title, header)
  local section = title
  local content = ''
  local continuation = header:match(title .. "(.*)")

  for line in continuation:gmatch("([^\n]*\n?)") do
    if line:match("%w+:\n") then
      break
    end
    section = section .. line
    content = content .. line
  end

  return self:new({
    title = title,
    text = section,
    content = content,
  })
end

--- Find and extract all sections from a header
-- Very opinionated.
-- @param header string: The header to parse
-- @return table: A list of Section objects
function Section:all_from_header(header)
  local t = {}

  for section_title in header:gmatch("(%w+:\n)") do
    t[section_title:match("%w+"):lower()] = Section:from_header(section_title, header)
  end

  return t
end
