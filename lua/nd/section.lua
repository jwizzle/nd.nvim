require('nd/link')

Section = {
  title = '',
  text = '',
  content = '',
}

function Section:new (opts)
  opts = opts or {}

  setmetatable(opts, self)
  self.__index = self

  return opts
end

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

function Section:all_from_header(header)
  local t = {}

  for section_title in header:gmatch("(%w+:\n)") do
    t[section_title:match("%w+"):lower()] = Section:from_header(section_title, header)
  end

  return t
end
