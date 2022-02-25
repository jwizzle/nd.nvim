package = "notitiedoos"
version = "dev-1"
source = {
   url = "git+ssh://git@github.com/jwizzle/nd.nvim.git"
}
description = {
   summary = "## What is this?",
   detailed = "## What is this?",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
build = {
   type = "builtin",
   modules = {
      nd = "lua/nd.lua",
      ["nd.actions"] = "lua/nd/actions.lua",
      ["nd.box"] = "lua/nd/box.lua",
      ["nd.json"] = "lua/nd/json.lua",
      ["nd.link"] = "lua/nd/link.lua",
      ["nd.note"] = "lua/nd/note.lua",
      ["nd.section"] = "lua/nd/section.lua",
      ["nd.shortcuts"] = "lua/nd/shortcuts.lua",
      ["nd.telescope.actions"] = "lua/nd/telescope/actions.lua",
      ["nd.telescope.init"] = "lua/nd/telescope/init.lua",
      ["nd.telescope.pickers"] = "lua/nd/telescope/pickers.lua",
      ["nd.utils"] = "lua/nd/utils.lua"
   }
}
