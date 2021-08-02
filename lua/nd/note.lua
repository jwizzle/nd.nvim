local nd = require('nd')

Note = {
  tags = {},
  date = '',
  title = '',
  links = {},
  path = '',
  link = '',
}

function Note:new (opts)
  opts = opts or {}
  setmetatable(opts, self)

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
    for name, link in string.gmatch(header, nd.note_opts.link_pattern) do
      if not link then
        -- This is actually the link in these cases
        table.insert(t, name)
      else
        t[name] = link
      end
    end
    return t
  end

  return self:new({
    title = string.match(header, nd.note_opts.title_pattern),
    date = string.match(header, nd.note_opts.date_pattern),
    tags = tags_from_header(),
    links = links_from_header(),
    link = "[["..string.match(path, "[/%g+]+/(%g+)$").."]]",
    path = path,
  })
end
