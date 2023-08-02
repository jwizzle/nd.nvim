local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = "3.0"
package = "nd.nvim"
version = _MODREV .. _SPECREV
source = {
   url = "git+ssh://git@github.com/jwizzle/nd.nvim.git"
}
description = {
   summary = "Zettelkasten plug-in for neovim, heavily leveraging telescope.nvim",
   detailed = "Zettelkasten plug-in for neovim, heavily leveraging telescope.nvim",
   homepage = "github.com/jwizzle/nd.nvim",
   license = "wtfpl"
}
build = {
   type = "builtin",
   modules = {
      nd = "lua/nd.lua",
      ["nd.actions"] = "lua/nd/actions.lua",
      ["nd.json"] = "lua/nd/json.lua",
      ["nd.shortcuts"] = "lua/nd/shortcuts.lua",
      ["nd.telescope.actions"] = "lua/nd/telescope/actions.lua",
      ["nd.telescope.init"] = "lua/nd/telescope/init.lua",
      ["nd.telescope.pickers"] = "lua/nd/telescope/pickers.lua",
      ["nd.utils"] = "lua/nd/utils.lua"
   },
   copy_directories = {
      "docs",
      "plugin"
   }
}
dependencies = {
   "luasocket",
}
