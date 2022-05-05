--- Actions used internally by the exposed telescope commands in init.lua.
local actions = require('telescope.actions')
local action_state = require'telescope.actions.state'
local nd = require("nd")

local a = {}

--- Insert a link under cursor.
-- @param prompt_bufnr int: Buffer number
a.insert_link = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  print(require('nd/json').encode(selection.value))
  vim.cmd(string.format([[
      exe "normal! a\[\[%s\]\]\<Esc>"
    ]], selection.value.filename))
end

--- Pick a tag to find notes for.
-- @param prompt_bufnr int: Buffer number
a.open_tag = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local pickers = require('nd/telescope/pickers')
  pickers.table(selection.value, nd.actions.notes_with_tag, {action_param = selection.value})
end

--- Open a selected note
-- @param prompt_bufnr int: Buffer number
a.open_note = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local filepath = selection.value
  actions.close(prompt_bufnr)

  filepath = selection.value.path

  vim.api.nvim_command(":e " .. filepath)
end

return a
