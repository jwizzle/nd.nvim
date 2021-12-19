--- Set up shortcuts
-- Only enabled when working on a zettel/note
local nd = require('nd')
local sc = {}

--- Map a shortcut to a function.
-- @param shortcut string: The shortcut to set up, vim notation
-- @param exec string: Lua code to execute
sc.map = function(shortcut, exec)
  local autocmd_pattern = nd.dir..'/*'..nd.suffix

  vim.cmd(string.format([[
    autocmd BufEnter %s map %s <cmd>lua %s<CR>
    ]], autocmd_pattern, shortcut, exec))
end

--- Set up shortcuts from given options.
-- @param opts table: Table of options/shortcuts
sc.setup = function (opts)
  opts = opts or {}
  for k, v in pairs(opts) do sc[k] = v end

  for k, v in pairs(sc.general) do
    if v then
      local actionstring = string.format("require('nd').actions.%s()", k)
      sc.map(v, actionstring)
    end
  end
  for k, v in pairs(sc.telescope) do
    if v then
      local actionstring = string.format("require('nd/telescope').%s()", k)
      sc.map(v, actionstring)
    end
  end
end

return sc
