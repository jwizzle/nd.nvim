local box = require('nd/box')

local nd = {
  dir = '~/zettelkasten', -- Your zettelkast directory
  open_new = true, -- Instantly open a newly created zettel
  header_datestring = "%Y-%m-%dT%H:%M", -- Header datestring
  prefix = "%H%M%S_%Y%m%d", -- File/zettel prefix, takes datestrings
  suffix = ".md", -- File/zettel suffix
  disable_shortcuts = false, -- Disable all shortcuts
  shortcuts = { -- Set individual shortcuts to false to disable
    linkjump = '<C-]>',
    sync_links = 'zll'
  },
  note_opts = { -- How to interpret your zettels/headers
    cachepath = '/tmp/zetteltmp',
    pattern_set = 'plain', -- The pattern set to use, see the README for more info
    pattern_sets = { -- Can be expanded on
      plain = {
        header_pattern = "%-%-%-(.-)%-%-%-", -- How to find the header in your zettel
        link_pattern = "(%[%[%g+%]%])", -- How to identify links in your header
        tag_pattern = "(#[%g ]+)", -- How to identify tags in your header
        title_pattern = "title: (.-)\n", -- How to identify the title in your header
        date_pattern = "date: (.-)\n", -- How to identify the date in your header
      },
      notitiedoos = {
        header_pattern = "%-%-%-(.-)%-%-%-",
        link_pattern = "- ?([%g ]+): (%[%[%g+%]%])",
        tag_pattern = "- ?(#[%g ]+)",
        title_pattern = "title: (.-)\n",
        date_pattern = "date: (.-)\n",
      },
    },
    -- Overwrite individual patterns of a set by defining them directly in note_opts
    -- header_pattern = "$mypattern"
  },
  header = [[
---
date: ${date}
title: ${title}
tags:
links:
---

# ${title}

]], -- Template for new zettels, can interpolate date and title
}

nd.load_patterns = function ()
  for k, v in pairs(nd.note_opts.pattern_sets[nd.note_opts.pattern_set]) do
    if not nd.note_opts[k] then
      nd.note_opts[k] = v
    end
  end
end

nd.setup = function (opts)
  -- Merge opts
  opts = opts or {}
  for k, v in pairs(opts) do nd[k] = v end

  -- Possibly expand ~ to homedir
  if string.sub(nd.dir, 1, 1) == '~' then
    local substr = nd.dir:gsub('~', '')
    nd.dir = os.getenv("HOME") .. substr
  end

  -- Merge patterns
  nd.load_patterns()

  -- Initialize notes
  local note_opts = nd.note_opts
  note_opts.dir = nd.dir
  note_opts.suffix = nd.suffix
  box.setup(note_opts)

  -- Load actions
  nd.actions = require("nd/actions")

  -- Initialize shortcuts
  if not nd.disable_shortcuts then require('nd/shortcuts').setup(nd.shortcuts) end

  -- print(require('nd/json').encode(nd.actions.notes_with_tag('awk')))
end

return nd
