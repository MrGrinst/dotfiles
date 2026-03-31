-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require("kyle.plugins")
require("kyle.remap")
require("kyle.vim-options")

local function setup_nvim_listen_socket()
  local tmux_pane = os.getenv("TMUX_PANE")
  if not tmux_pane then
    return
  end

  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not git_root or git_root == "" then
    git_root = vim.fn.getcwd()
  end

  local sanitized = git_root:gsub("[^%w]", "-"):gsub("^%-+", ""):gsub("%-+$", "")
  local pane_id = tmux_pane:gsub("%%", "")
  local sock = "/tmp/nvim-" .. sanitized .. "-" .. pane_id .. ".sock"

  if vim.fn.filereadable(sock) == 1 then
    os.remove(sock)
  end

  vim.fn.serverstart(sock)
end

setup_nvim_listen_socket()
