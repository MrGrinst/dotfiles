local dap = require "dap"
local ui = require "dapui"

require("dapui").setup()
require('dap-cs').setup()

-- Eval var under cursor
vim.keymap.set("n", "g/", function()
  require("dapui").eval(nil, { enter = true })
end)

vim.keymap.set("n", "gm", dap.toggle_breakpoint)
vim.keymap.set("n", "gc", dap.continue)
vim.keymap.set("n", "gi", dap.step_into)
vim.keymap.set("n", "gn", dap.step_over)
vim.keymap.set("n", "go", dap.step_out)

dap.listeners.before.attach.dapui_config = function()
  ui.open()
end
dap.listeners.before.launch.dapui_config = function()
  ui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  ui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  ui.close()
end
