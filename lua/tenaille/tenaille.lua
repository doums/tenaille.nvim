-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at https://mozilla.org/MPL/2.0/.

local M = {}

local _pairs = {}

local quotes = { '"', "'", '`' }

-- TODO use nvim_buf_set_lines to make surround changes

local function get_selection()
  local v_pos = vim.list_slice(vim.fn.getpos('v'), 2, 3)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local pos_start = { row = v_pos[1], col = v_pos[2] }
  local pos_end = { row = cursor_pos[1], col = cursor_pos[2] + 1 }
  local c_pos = 'end'

  -- if cursor is located at the start of the selection, swap
  -- start and end positions
  if
    pos_start.row > pos_end.row
    or (pos_start.row == pos_end.row and pos_start.col > pos_end.col)
  then
    c_pos = 'start'
    local tmp = pos_start
    pos_start = pos_end
    pos_end = tmp
  end

  local lines =
    vim.api.nvim_buf_get_lines(0, pos_start.row - 1, pos_end.row, false)
  local l_start = lines[1]
  local l_end = lines[#lines]
  local c_start = l_start:sub(pos_start.col, pos_start.col)
  local c_end = l_end:sub(pos_end.col, pos_end.col)

  local delimited_by = vim.iter(_pairs):find(function(pair)
    return pair[1] == c_start and pair[2] == c_end
  end)
  local is_quoted = false
  local is_bracketed = false
  if delimited_by then
    local quoted = vim.list_contains(quotes, delimited_by[1])
    if quoted then
      is_quoted = true
    else
      is_bracketed = true
    end
  end

  local is_multiline = pos_start.row ~= pos_end.row

  -- make positions 0,0 indexed
  pos_start.row = pos_start.row - 1
  pos_start.col = pos_start.col - 1
  pos_end.row = pos_end.row - 1
  pos_end.col = pos_end.col - 1

  -- if selection end col is at the eol, offset it by one cell
  if pos_end.col >= string.len(l_end) then
    pos_end.col = pos_end.col - 1
  end

  return {
    start = {
      pos = pos_start,
      char = c_start,
      line = lines[1],
      is_empty_line = string.len(l_start) == 0,
    },
    ['end'] = {
      pos = pos_end,
      char = c_end,
      line = lines[#lines],
      is_empty_line = string.len(l_end) == 0,
    },
    is_multiline = is_multiline,
    is_bracketed = is_bracketed,
    is_quoted = is_quoted,
    cursor_pos = c_pos,
  }
end

local function wrap_by(sel, pair)
  local start_pos = sel.start.pos
  local end_pos = sel['end'].pos

  -- insert the open character of the pair
  vim.api.nvim_buf_set_text(
    0,
    start_pos.row,
    start_pos.col,
    start_pos.row,
    start_pos.col,
    { pair[1] }
  )

  local end_col
  if sel.is_multiline then
    end_col = sel['end'].is_empty_line and 0 or end_pos.col + 1
  else
    end_col = sel['end'].is_empty_line and 1 or end_pos.col + 2
  end

  -- insert the close character of the pair
  vim.api.nvim_buf_set_text(
    0,
    end_pos.row,
    end_col,
    end_pos.row,
    end_col,
    { pair[2] }
  )
end

local function replace_by(sel, pair)
  local start_pos = sel.start.pos
  local end_pos = sel['end'].pos

  -- insert the open character of the pair
  vim.api.nvim_buf_set_text(
    0,
    start_pos.row,
    start_pos.col,
    start_pos.row,
    start_pos.col + 1,
    { pair[1] }
  )

  -- insert the close character of the pair
  vim.api.nvim_buf_set_text(
    0,
    end_pos.row,
    end_pos.col,
    end_pos.row,
    end_pos.col + 1,
    { pair[2] }
  )
end

local function update_sel(sel, start_offset, end_offset)
  -- if cursor is located at end of the selection, move it to
  -- the start
  if sel.cursor_pos == 'end' then
    vim.cmd('normal! o')
  end

  local start_col = sel.start.pos.col + start_offset
  local end_col = sel['end'].pos.col + end_offset
  if end_col < 0 then
    end_col = 0
  end

  -- move the start of the selection
  if start_offset then
    vim.api.nvim_win_set_cursor(0, { sel.start.pos.row + 1, start_col })
  end

  -- switch to the end of selection
  vim.cmd('normal! o')

  -- move the end of the selection
  vim.api.nvim_win_set_cursor(0, { sel['end'].pos.row + 1, end_col })

  -- if the cursor was initially located at start of selection
  -- switch it back
  if sel.cursor_pos == 'start' then
    vim.cmd('normal! o')
  end
end

function M.wrap(pair)
  local mode = vim.api.nvim_get_mode()
  if not mode.mode:match('[vV]') then
    return
  end
  local sel = get_selection()
  -- vim.print(sel)
  local is_quotes = vim.list_contains(quotes, pair[1])

  -- if current selection is quoted by "'` and the input pair is
  -- quotes but a different pair, replace with the input pair
  -- |"abc"| → ' → '|abc|'
  if sel.is_quoted and is_quotes and sel.start.char ~= pair[1] then
    replace_by(sel, pair)
    update_sel(sel, 1, -1)
    return
  end

  -- if current selection is bracketed by {}[]()<> and the input
  -- pair is brackets but a different pair, replace with the input
  -- pair
  -- |[abc]| → ( → (|abc|)
  if sel.is_bracketed and not is_quotes and sel.start.char ~= pair[1] then
    replace_by(sel, pair)
    update_sel(sel, 1, -1)
    return
  end

  -- if current selection is quoted by "'` and the input pair is
  -- the same, just select inner
  -- |"abc"| → " → "|abc|"
  if sel.is_quoted and sel.start.char == pair[1] then
    update_sel(sel, 1, -1)
    return
  end

  -- for any other cases just wrap the selection
  -- |abc| → [ → "[|abc|]"
  wrap_by(sel, pair)
  if sel.is_multiline then
    update_sel(sel, 1, 0)
  else
    update_sel(sel, 1, 1)
  end
end

function M.init(config)
  _pairs = config.pairs
  if config.default_mapping then
    for _, pair in ipairs(_pairs) do
      vim.keymap.set('v', '<leader>' .. pair[1], function()
        M.wrap(pair)
      end)
    end
  end
end

return M
