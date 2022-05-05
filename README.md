# Nd.nvim - Notitiedoos/zettelkasten

## LEGACY BRANCH

Caution: This is a legacy branch of notitiedoos, completely written in lua.
The original project I've mostly replaced with zettelgo.

## What is this?

Notitiedoos is a Neovim plug-in that helps managing and navigating your [zettelkasten](https://zettelkasten.de/posts/overview/).
Mainly by providing [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) interfaces and autojumping to links under your cursor for now. But all actions used by the telescope pickers are also available directly, returning lua tables with results that you can use to populate a fuzzyfinder of your choice.

It works by gathering the notes from your configured zettelkasten directory, and parsing data from the headers of your zettels. Which means there are some restrictions on what these notes are supposed to look like before all goodies are available/work correctly. I've written this with configurability and compatibility in mind as much as possible.

The state of this project is currently very new. It works great on my machine, and that's as much as it's been tested. This is the first neovim plug-in I've made so far, and the first lua project. So any and all feedback is welcome.
Most of the functionality I was looking for myself has been implemented, the way it is used probably won't change in the near future but code is still being rewritten as I go and learn lua. Some new functionality might be added. Reported issues will be looked at whenever I feel like it. Feature requests will be considered if they're in line with something I want, merge requests are better.

### Available goodies

* Creates a table with information about your zettels to make navigation a breeze (asynchronously/non-blocking)
  * Search through your zettels with telescope live_grep and find_files from any directory
  * Explore linked notes with telescope
  * Navigate tags and notes that include them
* Create new zettels from a template with placeholders for title and date
* Pick a note from telescope, insert a link to it under cursor
* Jump to links under your cursor
* Keep links in sync between zettels
* Should work out of the box, while being customizable enough to work around differences in zettelkasten set-ups
  * Most heavy-lifting is done by configurable lua pattern strings

### Showcase

[![asciicast](https://asciinema.org/a/Pdwr4B2nHDyOA6ovi5SxvnICf.svg)](https://asciinema.org/a/Pdwr4B2nHDyOA6ovi5SxvnICf)

Spoiler: when adding a new zettel you see me hessitate to name it 'note 3' instead of 'note3'. At that moment I realized it would create the file with a space, which is horrendous. This is now fixed, if you input the title with a space the header title will contain a space. In the filename this is replaced by an underscore.
I am too lazy to record it anew.

## Installation

```lua
-- Packer
use {'jwizzle/nd.nvim', requires = {{'nvim-telescope/telescope.nvim'}, {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}}

-- Somewhere in your config
require('nd').setup()
```

## Usage

See configuration for default shortcuts. Those will be local to files in your zettelkasten directory only and will not influence other buffers.
You might want to run certain actions like finding zettels or creating new ones outside of that directory too. See the custom shortcut example below.

I personally have set the find_notes action in my init.lua to access my notes from anywhere. From that point I use the built-in commands to navigate further. And kept the new command separate to be able to start a new idea from anywhere.

### Custom shortcut example

```lua
-- Create a new zettel
vim.api.nvim_set_keymap('n', '<leader>zn', "<cmd>lua require('nd').actions.new()<CR>", {})
-- Sync object in memory with file status, probably never needed
vim.api.nvim_set_keymap('n', '<leader>zg', "<cmd>lua require('nd').actions.gather()<CR>", {})
-- Use telescope to find notes by path
vim.api.nvim_set_keymap('n', '<leader>zf', "<cmd>lua require('nd/telescope').find_notes()<CR>", {})
-- Use telescope to browse links to this zettel
vim.api.nvim_set_keymap('n', '<leader>zlt', "<cmd>lua require('nd/telescope').find_links_to()<CR>", {})
-- Use telescope to browse links from this note
vim.api.nvim_set_keymap('n', '<leader>zlf', "<cmd>lua require('nd/telescope').find_links_from()<CR>", {})
-- Use telescope to pick a link to insert under cursor
vim.api.nvim_set_keymap('n', '<leader>zll', "<cmd>lua require('nd/telescope').insert_link()<CR>", {})
-- Use telescope to explore tags
vim.api.nvim_set_keymap('n', '<leader>zt', "<cmd>lua require('nd/telescope').find_tags()<CR>", {})
-- Use telescope to live-grep in zettel folder
vim.api.nvim_set_keymap('n', '<leader>zr', '<cmd>lua require("nd/telescope").live_grep()<CR>', {})
-- Make sure all links in the current note also link back to this one -- Requires a links: section in your headers. Use with caution if your header setup differs.
vim.api.nvim_set_keymap('n', '<leader>zls', "<cmd>lua require('nd').actions.sync_links()<CR>", {}) -- Make 
-- Make sure all links in all notes link back to each other -- Requires a links: section in your headers. Use with caution if your header setup differs.
vim.api.nvim_set_keymap('n', '<leader>zlS', "<cmd>lua require('nd').actions.sync_all_links()<CR>", {})
```

### About zettels

Zettels/notes are gathered and parsed by the plug-in to be able to find links between them.
Parsing is done by pattern matching, which means a few elements must exist in your zettels.

This is what a note could look like:
```
---
date: 2021-07-14T22:19 //optional
title: note1  //mandatory
tags: //not necessarily required in this format, just tag tags with #
  - #tag1
  - #tag2
links: // note required in this format, just mark links with [[]]
  - note2: [[214806_20210714_note2.md]] //Links can contain the full filename
  - [[note3]] // links can also contain just the title

[[note 4]] // The list structure i use also isn't mandatory and you can use spaces in titles
---

# title

Everything outside the header is unimportant. In the scope of this plug-in.
```

### Example configuration

With defaults shown.

```lua
require('nd').setup({
  dir = '~/zettelkasten', -- Your zettelkast directory
  open_new = true, -- Instantly open a newly created zettel
  header_datestring = "%Y-%m-%dT%H:%M", -- Header datestring
  prefix = "%H%M%S_%Y%m%d", -- File/zettel prefix, takes datestrings
  suffix = ".md", -- File/zettel suffix
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
  note_opts = { -- How to interpret your zettels/headers
    cachepath = '/tmp/zetteltmp',
    pattern_set = 'plain', -- The pattern set to use, can be overridden individually
    pattern_sets = { -- Can be expanded on, mostly here for legacy reasons
      plain = {
        header_pattern = "%-%-%-(.-)%-%-%-", -- How to find the header in your zettel
        link_pattern = "(%[%[%g+%]%])", -- How to identify links in your header
        tag_pattern = "(#[%g ]+)", -- How to identify tags in your header
        title_pattern = "title: (.-)\n", -- How to identify the title in your header
        date_pattern = "date: (.-)\n", -- How to identify the date in your header
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
```

## Todo

* Also load links from content, if they exist only, try parsing everything between [[]]
* Should the notefinding/box functionality be more decoupled from usage in nvim?
* Renaming zettels
* More telescope shortcuts
* Actions to fill the header of current file with links/tags from zettel contents
* Some caching mechanism/optimizations/prefetching
* Telescope alternatives/native tools
