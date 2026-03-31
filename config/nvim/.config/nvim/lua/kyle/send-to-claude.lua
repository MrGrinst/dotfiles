local M = {}

local function find_claude_panes()
  local pane_output = vim.fn.system("tmux list-panes -a -F '#{pane_id} #{pane_pid}'")
  if vim.v.shell_error ~= 0 then
    return {}
  end

  local ps_output = vim.fn.system("ps -eo pid,ppid,comm")
  local children = {}
  for line in ps_output:gmatch("[^\n]+") do
    local pid, ppid, comm = line:match("^%s*(%d+)%s+(%d+)%s+(.+)$")
    if pid then
      children[ppid] = children[ppid] or {}
      table.insert(children[ppid], { pid = pid, comm = comm })
    end
  end

  local function has_claude_descendant(pid)
    if not children[pid] then
      return false
    end
    for _, child in ipairs(children[pid]) do
      if child.comm:match("claude") then
        return true
      end
      if has_claude_descendant(child.pid) then
        return true
      end
    end
    return false
  end

  local panes = {}
  for line in pane_output:gmatch("[^\n]+") do
    local pane_id, pane_pid = line:match("^(%S+)%s+(%S+)$")
    if pane_id and has_claude_descendant(pane_pid) then
      local cwd = vim.fn.system("tmux display-message -p -t " .. pane_id .. " '#{pane_current_path}'"):gsub("\n$", "")
      table.insert(panes, { pane_id = pane_id, cwd = cwd })
    end
  end
  return panes
end

local function select_best_pane(panes, current_dir)
  local best = nil
  local best_len = -1

  for _, pane in ipairs(panes) do
    local cwd = pane.cwd
    if not cwd:match("/$") then
      cwd = cwd .. "/"
    end
    if current_dir:sub(1, #cwd) == cwd or current_dir == pane.cwd then
      if #pane.cwd > best_len then
        best = pane
        best_len = #pane.cwd
      end
    end
  end

  if best then
    return best
  end

  for _, pane in ipairs(panes) do
    local len = 0
    for i = 1, math.min(#pane.cwd, #current_dir) do
      if pane.cwd:sub(i, i) == current_dir:sub(i, i) then
        len = i
      else
        break
      end
    end
    if len > best_len then
      best = pane
      best_len = len
    end
  end
  return best
end

local function get_text(mode)
  if mode == "v" then
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local min_indent = math.huge
    for _, line in ipairs(lines) do
      if line:match("%S") then
        local indent = line:match("^%s*"):len()
        if indent < min_indent then
          min_indent = indent
        end
      end
    end
    if min_indent == math.huge then
      min_indent = 0
    end
    for i, line in ipairs(lines) do
      lines[i] = line:sub(min_indent + 1)
    end
    return table.concat(lines, "\n"), start_line
  else
    return vim.api.nvim_get_current_line(), vim.fn.line(".")
  end
end

local function send_to_claude(pane_id, message)
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Failed to create temp file", vim.log.levels.ERROR)
    return
  end
  f:write(message)
  f:close()
  vim.fn.system("tmux load-buffer " .. vim.fn.shellescape(tmpfile))
  vim.fn.system("tmux paste-buffer -t " .. vim.fn.shellescape(pane_id) .. " -d")
  os.remove(tmpfile)
end

function M.prompt_and_send(mode)
  if not vim.env.TMUX then
    vim.notify("Not in a tmux session", vim.log.levels.ERROR)
    return
  end

  local text, start_line
  if mode == "v" then
    vim.cmd('noautocmd normal! "zy')
    text, start_line = get_text("v")
  else
    text, start_line = get_text("n")
  end

  local panes = find_claude_panes()
  if #panes == 0 then
    vim.notify("No Claude Code panes found", vim.log.levels.ERROR)
    return
  end

  local current_dir = vim.fn.getcwd()
  local pane = select_best_pane(panes, current_dir)
  if not pane then
    vim.notify("No matching Claude Code pane found", vim.log.levels.ERROR)
    return
  end

  local relative_path = vim.fn.expand("%:.")
  local filetype = vim.bo.filetype

  vim.ui.input({ prompt = "Claude: " }, function(commentary)
    if commentary == nil then
      return
    end

    local parts = {}
    local file_ref = relative_path .. ":" .. start_line
    local is_single_short = not text:match("\n") and #text <= 80

    if commentary ~= "" then
      table.insert(parts, commentary)
    end

    if is_single_short then
      table.insert(parts, "`" .. file_ref .. "`: `" .. text .. "`")
    else
      table.insert(parts, "`" .. file_ref .. "`:")
      table.insert(parts, "```" .. filetype .. "\n" .. text .. "\n```")
    end

    local message = "\n" .. table.concat(parts, "\n") .. "\n"
    send_to_claude(pane.pane_id, message)
    vim.notify("Sent to Claude Code")
  end)
end

return M
