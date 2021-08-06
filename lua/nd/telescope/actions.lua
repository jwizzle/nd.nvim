local actions = require('telescope.actions')
local action_state = require'telescope.actions.state'
local nd = require("nd")

local a = {}

a.insert_link = function (prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  vim.cmd(string.format([[
      exe "normal! a%s \<Esc>"
    ]], selection.value.link))
end

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

  filepath = selection.value.path

  vim.api.nvim_command(":e " .. filepath)
end

return a
