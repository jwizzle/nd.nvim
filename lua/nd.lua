local utils = require("nd/utils")

--- Notitiedoos, a zettelkasten plugin for neovim, leveraging telescope and zettelgo.
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
      rename = 'zrn'
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
  localbinary = false
}

vim.api.nvim_create_user_command(
    'NdInstall',
    function()
      local datadir = debug.getinfo(1).source:match("@?(.*/)")
      nd.localbinary = datadir .. "zettelgo"
      local uname = utils.os_capture("uname -m")
      local arch = ""

      if uname == "x86_64" then
        arch = "amd64"
      elseif uname == "arm32" then
        arch = "arm"
      elseif uname == "arm64" then
        arch = "arm64"
      elseif uname == "i386" then
        arch = "386"
      else
        print("Not on a supported platform for :NdInstall, try compiling zettelgo manually (see: github.com/jwizzle/zettelgo).")
        return
      end

      local zettelgo_release = "https://github.com/jwizzle/zettelgo/releases/download/v1.0.4/zettelgo-linux-" .. arch

      utils.os_capture("wget -nv -O " .. nd.localbinary .. " " .. zettelgo_release .. " 2>&1")
      utils.os_capture("chmod -v +x " .. nd.localbinary)

      print("Downloaded zettelgo to: " .. nd.localbinary)
    end,
    {}
)

--- Setup the notitiedoos module
-- Load merge opts, set up a environment, etc.
-- @param opts table: Table of options to parse
-- @return None
nd.setup = function (opts)
  -- Merge opts
  opts = opts or {}
  for k, v in pairs(opts) do nd[k] = v end

  -- Set zetteldir
  nd.dir = require('nd/utils').zettelgoflatcmd('cfg show Directory', nd.localbinary)
  -- Set datadir
  nd.datadir = debug.getinfo(1).source:match("@?(.*/)")
  local loc = nd.datadir .. "zettelgo"
  local f=io.open(loc,"r")
  if f~=nil then
    io.close(f)
    nd.localbinary = loc
  else
    nd.localbinary = false
  end
  -- Set note suffix
  nd.suffix = require('nd/utils').zettelgoflatcmd('cfg show Note_suffix', nd.localbinary)

  -- Load actions
  nd.actions = require("nd/actions")

  -- Initialize shortcuts
  if not nd.disable_shortcuts then require('nd/shortcuts').setup(nd.shortcuts) end
end

return nd
