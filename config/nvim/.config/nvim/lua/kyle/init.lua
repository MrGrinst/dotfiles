-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require("kyle.plugins")
require("kyle.remap")
require("kyle.vim-options")

-- Expose a per-pane server socket so `nvim-open` can route files from macOS
-- into the nvim already running in this tmux pane.
local function setup_nvim_listen_socket()
  local tmux_pane = os.getenv("TMUX_PANE")
  if not tmux_pane then
    return
  end

  local sock = "/tmp/nvim-" .. tmux_pane:gsub("%%", "") .. ".sock"

  if vim.fn.filereadable(sock) == 1 then
    os.remove(sock)
  end

  vim.fn.serverstart(sock)
end

setup_nvim_listen_socket()
