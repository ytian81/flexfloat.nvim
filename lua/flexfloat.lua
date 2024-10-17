local M = {}

local function is_tmux_running()
  return os.getenv("TMUX") ~= nil
end

function M.open_selected_file(filename_path)
  if vim.fn.filereadable(filename_path) == 0 then
    return
  end

  local file = vim.fn.readfile(filename_path)
  if #file == 0 then
    return
  end

  local filename = file[1]

  local file_opener_path = '/tmp/yazi_vim_opener'
  local open_command = 'edit'

  if vim.fn.filereadable(file_opener_path) == 1 then
    local opener_file = vim.fn.readfile(file_opener_path)
    if #opener_file > 0 then
      open_command = opener_file[1]
    end
  end

  print("Opening file: " .. filename)
  vim.cmd(open_command .. ' ' .. vim.fn.fnameescape(filename))
end

function M.run_neovim_floating_window(open_hook, close_hook)
  local width = vim.o.columns
  local height = vim.o.lines

  local win_height = math.floor(height * 0.8) + 2
  local win_width = math.floor(width * 0.8)
  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = win_width,
    height = win_height,
    style = 'minimal',
    border = 'single'
  })

  vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Normal,FloatBorder:Comment')

  vim.fn.termopen(open_hook, {
    on_exit = function()
      vim.api.nvim_win_close(win, true)
      close_hook("/tmp/yazi_selected")
    end
  })

  vim.cmd('startinsert')
end

function M.run_tmux_popup_window(open_hook, close_hook)
  local command = 'tmux popup -E -w80% -h80% "' .. open_hook .. '"'
  os.execute(command)

  close_hook("/tmp/yazi_selected")
end

function M.open_explorer(dir)
  dir = dir or '.'
  local filename_path = '/tmp/yazi_selected'
  os.execute("rm -rf " .. filename_path)
  local open_hook = 'yazi --chooser-file=' .. filename_path .. ' ' .. dir
  local close_hook = M.open_selected_file

  if is_tmux_running() then
    M.run_tmux_popup_window(open_hook, close_hook)
  else
    M.run_neovim_floating_window(open_hook, close_hook)
  end
end

function M.handle_directory_open()
  local buf_path = vim.fn.expand("<amatch>")
  if vim.fn.isdirectory(buf_path) == 1 then
    vim.cmd('bdelete!')
    M.open_explorer(buf_path)
  end
end

return M
