## tenaille.nvim

Wrap the visual selection in brackets and quotes

### Install

As usual using your plugin manager, e.g. lazy.nvim

```lua
local P = {
  -- plugin spec
  'doums/tenaille.nvim',
  config = true,
}
```

### Config

```lua
local tenaille = require('tenaille')

-- Default config
tenaille.setup({
  -- generate default mapping for each pair using
  -- <leader>_open-character_
  -- i.e.
  -- <leader>" for double quotes ""
  -- <leader>[ for brackets []
  -- <leader>{ for curly braces {} and so on...
  default_mapping = true,
  -- supported brackets and quotes pairs
  -- ⚠ only 2 character pairs are supported
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

Select the text you want to wrap then press the relevant key
mapping

| before       | key         | after        |
|--------------|-------------|--------------|
| `\|text\|`   | `<Leader>[` | `[\|text\|]` |
| `\|text\|`   | `<Leader>"` | `"\|text\|"` |
| `\|[text]\|` | `<Leader>(` | `(\|text\|)` |
| `\|"text"\|` | `<Leader>'` | `'\|text\|'` |
| `\|"text"\|` | `<Leader>"` | `"\|text\|"` |

`|…|` _selection_

note: multiline selections are supported

### Custom mapping

```lua
tenaille.setup({
  -- disable default key mapping
  default_mapping = false,
)}

local wrap = require('tenaille').wrap

vim.keymap.set('v', '"', function() wrap({ '"', '"' }) end)
vim.keymap.set('v', "'", function() wrap({ "'", "'" }) end)
vim.keymap.set('v', '`', function() wrap({ '`', '`' }) end)
vim.keymap.set('v', '(', function() wrap({ '(', ')' }) end)
vim.keymap.set('v', '[', function() wrap({ '[', ']' }) end)
vim.keymap.set('v', '{', function() wrap({ '{', '}' }) end)
vim.keymap.set('v', '<', function() wrap({ '<', '>' }) end)
```

### License

Mozilla Public License 2.0
