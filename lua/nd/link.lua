local nd = require("nd")

Link = {
  text = '',
  target = '',
}

function Link:new (opts)
  opts = opts or {}
  setmetatable(opts, self)

  return opts
end

function Link:from_text (text)
  local target
  local content = text:match("%[%[(.-)%]%]")

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
