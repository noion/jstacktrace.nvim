local M = {}

M.setup = function()
  -- nothing
end

local state = {
  buf = nil,
  java_src_path = "src/main/java",
}

function M.parse_stacktrace()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local qf_list = {}
  local pattern = "at%s+(.-)%.(%w+)%(([%w]+.java):(%d+)%)"

  local root_path = vim.fn.getcwd()
  for _, line in ipairs(lines) do
    if not line:match("Caused by:") then
      local package_class, _, file, lnum = line:match(pattern)
      if package_class and file and lnum then
        local class_path = package_class:gsub("%.", "/") .. ".java"
        table.insert(qf_list, {
          filename = root_path .. "/" .. state.java_src_path .. class_path,
          lnum = tonumber(lnum),
          text = line,
        })
      end
    end
  end

  vim.api.nvim_buf_delete(state.buf, { force = true, unload = true })
  vim.fn.setqflist(qf_list)
  vim.api.nvim_command("copen")
end

local function open_window(buf)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = 120,
    height = 20,
    col = (vim.o.columns - 120) / 2,
    row = (vim.o.lines - 20) / 2,
    style = "minimal",
    border = "rounded",
  })
end

local function set_buffer_keymaps(buf)
  vim.keymap.set("n", "<leader>x", function()
    M.parse_stacktrace()
  end, { buffer = buf, silent = true, desc = "Parse stacktrace" })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_buf_delete(buf, { force = true, unload = true })
  end, { buffer = buf, silent = true })
end

local function create_buffer()
  local buf = state.buf
  if buf == nil then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", "java.stacktrace", { buf = buf })
    vim.api.nvim_buf_set_name(buf, "Java Stacktrace")
    state.buf = buf
  end
  return buf
end

function M.open_stacktrace_buffer()
  local buf = create_buffer()
  set_buffer_keymaps(buf)
  open_window(buf)
end

vim.api.nvim_create_user_command("JavaStackTrace", M.open_stacktrace_buffer, {})
vim.keymap.set("n", "<leader>st", ":JavaStackTrace<CR>")

return M
