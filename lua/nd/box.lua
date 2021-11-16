require('nd/note')

local async_lib = require "plenary.async_lib"
local async = async_lib.async
local run = async_lib.run
local await = async_lib.await
local utils = require('nd/utils')
local nd = require('nd')

Box = {
  notes = {},
  gathering = false,
}

function Box:gather_async ()
  local gather = async(function ()
    await(async_lib.scheduler())
    local output = utils.os_capture('find '..nd.dir.." -type f -not -path '*/\\.git/*'")
    local corrupt_notes = ''

    for filename in string.gmatch(output, "/%g+" .. nd.suffix) do
      local success, newnote = pcall(Note.from_path, Note, filename)
      if success then
        if Box.notes[newnote.title] then
          if Box.notes[newnote.title].path ~= newnote.path then
            print(newnote.title .. ' is declared multiple times.')
          end
        end
        Box.notes[newnote.title] = newnote
      else
        corrupt_notes = corrupt_notes .. newnote .. "\n"
      end
    end

    for _, note in pairs(Box.notes) do
      note:sync()
    end

    if corrupt_notes ~= '' then print(corrupt_notes) end
    self.gathering = false
  end)

  if not self.gathering then run(gather()); self.gathering = true end
end

function Box:by_filename (filename)
  local result = {}

  for _, note in pairs(self.notes) do
    if string.find(note.path, filename) then
      result = note
      break
    end
  end

  return result
end

function Box:by_title (title)
  local result = {}

  for _, note in pairs(self.notes) do
    if string.find(note.title:lower(), title:lower()) then
      result = note
      break
    end
  end

  return result
end

function Box:setup (opts)
  opts = opts or {}
  for k, v in pairs(opts) do self[k] = v end

  self:gather_async()

  return self
end
