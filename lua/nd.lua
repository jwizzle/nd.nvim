-- TODO Complete doc revamp for Go version.
--- Notitiedoos, a zettelkasten implementation in Neovim.
-- This is quite opinionated about what headers of zettels should look like for optimal performance.
-- But there should be some useful things even when not adhering to my set-up.
-- The aim is to make things more flexible as soon as more details about usage in general have been worked out.
local nd = {
  open_new = true, -- Instantly open a newly created zettel
  disable_shortcuts = false, -- Disable all shortcuts
  shortcuts = { -- Set individual shortcuts to false to disable, these are applied in a zettelkast buffer only
    general = {
      jump = '<C-]>',
      new = 'zn',
      gather = 'zG',
      sync_links = 'zls',
      sync_all_links = 'zlS',
    },
    telescope = {
      find_notes = 'zf',
      find_links_to = 'zlt',
      find_links_from = 'zlf',
      insert_link = 'zll',
      find_tags = 'zt',
      live_grep = 'zg',
    },
  },
}

--- Setup the notitiedoos module
-- Load patterns, merge opts, set up a box for notes, etc.
-- @param opts table: Table of options to parse
-- @return None
nd.setup = function (opts)
  -- Merge opts
  opts = opts or {}
  for k, v in pairs(opts) do nd[k] = v end

  -- Set zetteldir
  nd.dir = require('nd/utils').zettelgoflatcmd('cfg show Directory')
  -- Set note suffix
  nd.suffix = require('nd/utils').zettelgoflatcmd('cfg show Note_suffix')

  -- Load actions
  nd.actions = require("nd/actions")

  -- Initialize shortcuts
  if not nd.disable_shortcuts then require('nd/shortcuts').setup(nd.shortcuts) end

  -- print(require('nd/json').encode(nd.box.notes))
end

return nd
