## tenaille.nvim

Wrap the visual selection in brackets and quotes

### Install

As usual using your plugin manager, e.g. lazy.nvim

```lua
local P = {
  'doums/tenaille.nvim',
}

P.opts = {
  -- see "Config"
}

return P
```

### Config

```lua
local tenaille = require('tenaille')

-- Default config
tenaille.setup({
  -- generate default mapping for each pair using
  -- <leader>_open-character_
  -- e.g.
  -- <leader>" for double quotes
  -- <leader>[ for brackets and so on...
  default_mapping = true,
  -- supported brackets and quotes pairs
  pairs = {
    { '"', '"' },
    { "'", "'" },
    { '`', '`' },
    { '{', '}' },
    { '[', ']' },
    { '(', ')' },
    { '<', '>' },
  },
})
```

### Usage

_TODO_

### License

Mozilla Public License 2.0
