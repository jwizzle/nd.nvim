local nd = require('nd')
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

  if sc.linkjump then sc.map(sc.linkjump, "require('nd').actions.jump()") end
  if sc.sync_links then sc.map(sc.sync_links, "require('nd').actions.sync_links()") end
end

return sc
