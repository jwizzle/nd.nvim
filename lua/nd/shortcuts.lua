local nd = require('nd')
local utils = require("nd/utils")
local sc = {}

sc.map = function(shortcut, exec)
  local autocmd_pattern = nd.dir..'/*'..nd.suffix

  vim.cmd(string.format([[
    autocmd BufEnter %s map %s <cmd>lua %s<CR>
    ]], autocmd_pattern, shortcut, exec))
end

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
