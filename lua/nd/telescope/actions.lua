local actions = require('telescope.actions')
local action_state = require'telescope.actions.state'
local notes = require("nd/notes")
local nd = require("nd")

local a = {}

a.open_tag = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  local pickers = require('nd/telescope/pickers')
  pickers.table(selection.value, nd.actions.notes_with_tag, {action_param = selection.value})
end

a.open_note = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local filepath = selection.value
  actions.close(prompt_bufnr)

  if not string.find(selection.value, nd.suffix) and not string.find(selection.value, "/") then
    for _, note in pairs(notes.box) do
      if note.title == selection.value then
        filepath = note.path
        break
      end
    end
  elseif not string.find(selection.value, "^/.*") then
    filepath = nd.dir .. "/" .. selection.value:gsub("%[", ''):gsub("%]", '')
  end

  vim.api.nvim_command(":e " .. filepath)
end

return a
