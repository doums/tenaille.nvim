-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local M = {}

-- Default config
local _config = {
  default_mapping = true,
  pairs = {
    { '"', '"' },
    { "'", "'" },
    { '`', '`' },
    { '{', '}' },
    { '[', ']' },
    { '(', ')' },
    { '<', '>' },
  },
}

function M.init(config)
  _config = vim.tbl_deep_extend('force', _config, config or {})
  return _config
end

M.config = _config
return M
