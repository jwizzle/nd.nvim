--- Represent a link between notes.
local nd = require("nd")

Link = {
  text = '',
  target = '',
}

--- Instantiate a new link
-- @param opts table: A table of options
-- @return table: The link
function Link:new (opts)
  opts = opts or {}
  setmetatable(opts, self)

  return opts
end

--- Create a new link object from text.
-- @param text string: The text of the link, with or without [[]]
-- @return Link: The created link object
function Link:from_text (text)
  local target
  local content = text:gsub("%[", ''):gsub("%]", '')

  if content:find(nd.suffix) then
    target = nd.dir .. '/' .. content
  else
    target = nd.box:by_title(content).path
  end

  return self:new({
      text = text,
      target = target
    })
end
