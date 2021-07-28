# Nd.nvim - Notitiedoos/zettelkasten

## What is this?

Notitiedoos is a Neovim plug-in that helps managing and navigating your [zettelkasten](https://zettelkasten.de/posts/overview/).
Mainly by providing [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) interfaces and autojumping to links under your cursor for now. But all actions used by the telescope pickers are also available directly, returning lua tables with results that you can use to populate a fuzzyfinder of your choice.

It works by gathering the notes from your configured zettelkasten directory, and parsing data from the headers of your zettels. Which means there are some restrictions on what these notes are supposed to look like before all goodies are available/work correctly. I've written this with configurability and compatibility in mind as much as possible.

The state of this project is currently very new. It works great on my machine, and that's as much as it's been tested. This is the first neovim plug-in I've made so far, and the first lua project. So any and all feedback is welcome, all expectations are better dropped.
Most of the functionality I was looking for myself has been implemented, the rest is currently in the todo section. Reported issues will be looked at whenever I feel like it. Feature requests will be considered if they're in line with something I want, merge requests are better.

### Available goodies

* Creates a table with information about your zettels to make navigation a breeze
  * Search through your zettels with telescope live_grep and find_files from any directory
  * Explore linked notes with telescope
  * Navigate tags and notes that include them
* Create new zettels from a template with placeholders for title and date
* Pick a note from telescope, insert a link to it under cursor
* Jump to links under your cursor
* Should work out of the box, while being customizable enough to work around differences in zettelkasten set-ups
  * Most heavy-lifting is done by configurable lua pattern strings

### Showcase

Nicely displays how this is at a usable point, yet still kinda wonky with telescope previewers not acting as expected and such.
Update: Previewers now work as expected while displaying nice titles of notes to search through. This needs to be updated still.

[![asciicast](https://asciinema.org/a/427634.svg)](https://asciinema.org/a/427634)

## Installation

```lua
-- Packer
use {'jwizzle/nd.nvim', requires = {{'nvim-telescope/telescope.nvim'}, {'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}}

-- Somewhere in your config
require('nd').setup()
```

## Usage

### Shortcut example

```lua
vim.api.nvim_set_keymap('n', '<leader>zn', "<cmd>lua require('nd').actions.new()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zf', "<cmd>lua require('nd/telescope').find_notes()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zlt', "<cmd>lua require('nd/telescope').find_links_to()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zlf', "<cmd>lua require('nd/telescope').find_links_from()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zll', "<cmd>lua require('nd/telescope').insert_link()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zt', "<cmd>lua require('nd/telescope').find_tags()<CR>", {})
vim.api.nvim_set_keymap('n', '<leader>zr', '<cmd>lua require("nd/telescope").live_grep()<CR>', {})
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
  - note2: [[214806_20210714_note2.md]]
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
  shortcuts = { -- Set individual shortcuts to false to disable
    linkjump = '<C-]>',
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
})
```

## Todo

* Auto-creation of backlinks
* More telescope shortcuts
* Actions to fill the header of current file with links/tags from zettel contents
* Some caching mechanism/optimizations/prefetching
* Telescope alternatives/native tools

