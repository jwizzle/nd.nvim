--- Some random utilities I needed
local utils = {}

-- TODO Stderr freaks out
--- Execute zettelgo commands, return parsed json
-- @param cmd arguments for zettelgo
-- @return table: Table of parsed json
utils.zettelgocmd = function (cmd, binary)
  binary = binary or "zettelgo"
  local output = utils.os_capture(binary .. " " .. cmd)
  local function parsejson (text)
    local json = require('nd/json').decode(text)
    return json
  end

  local status, out = pcall(parsejson, output)
  if not status then
    out = {{
        path = "zettelgo " .. cmd .. " failed",
        title = "ERROR - See :messages"
      }}
  end

  return out
end

--- Execute a zettelgo command, return string
-- @param cmd arguments for zettelgo
-- @return string: Output of command
utils.zettelgoflatcmd = function (cmd, binary)
  binary = binary or "zettelgo"
  return utils.os_capture(binary .. " " .. cmd) or ""
end

--- Capture os command output
-- @param cmd string: Command to execute
-- @param raw bool: Capture raw?
utils.os_capture = function (cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  local exitcode = f:close()

  if s == "" or exitcode == nil then
    print("Cmd failed, try executing " .. cmd .. " manually and see what's wrong.")
    return nil
  end

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
