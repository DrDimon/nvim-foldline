local api = vim.api

OutlineBuffer = {
  main_buf_handle = -1,
  outline_buf_handle = -1
}

function OutlineBuffer:new (o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function OutlineBuffer:get_fold_info()

  -- Go to our main buffer:
  local current_buf_handle = api.nvim_win_get_buf(0)
  api.nvim_command('buffer ' .. self.main_buf_handle);

  local previous_fold_level = -1
  local num_lines = vim.api.nvim_buf_line_count(self.main_buf_handle)
  local result = {}

  -- expand all folds, or we won't find them all:
  api.nvim_command('normal! zR')
  local previous_line = 0

  while( true ) do
    -- Jump to the start of the next fold:
    api.nvim_command('keepjumps normal! zj')

    -- new line:
    local r,c = unpack(vim.api.nvim_win_get_cursor(0))

    -- if we found a new fold, extract the info:
    if previous_line == r then
      break
    else
      table.insert(result, r .. ' (' .. vim.fn.foldlevel(r) .. '): ' .. vim.fn.getline(r))
      previous_line = r
    end
  end

  -- restore the active buffer:
  api.nvim_command('buffer ' .. current_buf_handle)

  return result
end

function OutlineBuffer:refresh_outline()

  vim.api.nvim_buf_set_option(self.outline_buf_handle, 'modifiable', true)

  local fold_info = self:get_fold_info()
  api.nvim_buf_set_lines(self.outline_buf_handle, 0, -1, true, fold_info)

  vim.api.nvim_buf_set_option(self.outline_buf_handle, 'modifiable', false)
end

local function open_buffer()

  local main_buf_handle = api.nvim_win_get_buf(0)

  -- setup new buffer for the outline:
  local outline_buf_handle = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(outline_buf_handle, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(outline_buf_handle, 'modifiable', false)
  vim.api.nvim_buf_set_option(outline_buf_handle, 'bufhidden', 'delete')

  -- Create a split and put the new buffer inside it:
  api.nvim_command('40 vsplit')
  local window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(window, outline_buf_handle)


  -- TODO: delete this object if the buffer is deleted:
  local buffer = OutlineBuffer:new({main_buf_handle = main_buf_handle, outline_buf_handle = outline_buf_handle})

  -- setup content with the outline:
  buffer:refresh_outline()
end

return {
  open_buffer = open_buffer
}
