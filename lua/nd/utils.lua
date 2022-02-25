--- Some random utilities I needed
local utils = {}

utils.zettelgocmd = function (cmd)
  local output = utils.os_capture("zettelgo " .. cmd)
  local json = require('nd/json').decode(output)
  return json
end

--- Capture os command output
-- @param cmd string: Command to execute
-- @param raw bool: Capture raw?
utils.os_capture = function (cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

--- Replace values in a string.
-- @param s string: The string to replace values in
-- @param tab table: A table of find/replaces
-- @return string: Updated string
utils.interp = function (s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

--- Convert a list to a set
-- @param list table: A list of items
-- @return set: A set of items
function utils.set(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

return utils
