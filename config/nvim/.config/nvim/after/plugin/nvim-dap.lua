local dap = require "dap"
local ui = require "dapui"

require("dapui").setup()

vim.keymap.set("n", "gB", dap.toggle_breakpoint)

local function set_dap_keymaps()
  vim.keymap.set("n", "g/", function()
    ui.eval(nil, { enter = true })
  end, { desc = "DAP eval" })
  vim.keymap.set("n", "gc", dap.continue, { desc = "DAP continue" })
  vim.keymap.set("n", "gi", dap.step_into, { desc = "DAP step into" })
  vim.keymap.set("n", "gn", dap.step_over, { desc = "DAP step over" })
  vim.keymap.set("n", "go", dap.step_out, { desc = "DAP step out" })
end

local function remove_dap_keymaps()
  pcall(vim.keymap.del, "n", "g/")
  pcall(vim.keymap.del, "n", "gc")
  pcall(vim.keymap.del, "n", "gi")
  pcall(vim.keymap.del, "n", "gn")
  pcall(vim.keymap.del, "n", "go")
end

dap.listeners.before.attach.dapui_config = function()
  ui.open()
  set_dap_keymaps()
end
dap.listeners.before.launch.dapui_config = function()
  ui.open()
  set_dap_keymaps()
end
dap.listeners.before.event_terminated.dapui_config = function()
  ui.close()
  remove_dap_keymaps()
end
dap.listeners.before.event_exited.dapui_config = function()
  ui.close()
  remove_dap_keymaps()
end
