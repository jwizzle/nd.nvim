# Nd.nvim - Notitiedoos/zettelkasten

## What is this?

Notitiedoos is a Neovim plug-in that provides an interface (mostly by using telescope) to [zettelgo](https://github.com/jwizzle/zettelgo), an application to manage a [zettelkasten](https://zettelkasten.de/posts/overview/) directory on your system.
A legacy version is available under the 'legacy' branch, which is completely written in Lua, before I decided to completely rewrite the back-end in Go. Which I mostly did to learn, but also turned out to be much faster.

[Some auto-generated very limited docs.](https://jwizzle.github.io/nd.nvim/)

### Available goodies

* Creates a table with information about your zettels to make navigation a breeze
  * Search through your zettels with telescope live_grep and find_files from any directory
  * Explore linked notes with telescope
  * Navigate tags and notes that include them
* Create new zettels from a template with placeholders for title and date
* Pick a note from telescope, insert a link to it under cursor
* Jump to links under your cursor
* Keep links in sync between zettels

### Showcase

[![asciicast](https://asciinema.org/a/Pdwr4B2nHDyOA6ovi5SxvnICf.svg)](https://asciinema.org/a/Pdwr4B2nHDyOA6ovi5SxvnICf)

Spoiler: when adding a new zettel you see me hessitate to name it 'note 3' instead of 'note3'. At that moment I realized it would create the file with a space, which is horrendous. This is now fixed, if you input the title with a space the header title will contain a space. In the filename this is replaced by an underscore.
Also, this was recorded back on the legacy branch but functionality should be the same.
I am too lazy to record it anew.

## Installation

Notitiedoos depends on zettelgo, which is a Go binary.
The ':NdInstall' command is a simple wrapper that uses wget and chmod to place a binary in the same folder your package manager installed the nd.lua file to. Use your package manager to keep zettelgo up-to-date automatically. An example with packer is shown below.

Notitiedoos tries to fall back on 'zettelgo' in your path if :NdInstall is not ran.

```lua
-- Packer
use { 'jwizzle/nd.nvim',
  requires = {
    {'nvim-telescope/telescope.nvim'},
    {'nvim-lua/popup.nvim'},
    {'nvim-lua/plenary.nvim'}
  },
  run=':NdInstall',
  config = function()
    require('nd').setup()
  end,
}
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

See [zettelgo](https://github.com/jwizzle/zettelgo) for requirements on zettels/notes.

### Example configuration

With defaults shown.

```lua
require('nd').setup({
  open_new = true, -- Instantly open a newly created zettel
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
  }})
```

## Todo

* Renaming zettels
