-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local tenaille = require('tenaille.tenaille')
local cfg = require('tenaille.config')

local M = {}

function M.setup(config)
  config = cfg.init(config or {})
  tenaille.init(config)
end

M.wrap = tenaille.wrap
M.pairs = cfg.config.pairs
return M
