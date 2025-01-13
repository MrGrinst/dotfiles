local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-vitest"),
    require("neotest-rspec"),
    require("neotest-jest"),
  },
  output_panel = {
    enabled = true,
    open = "botright vsplit | vertical resize 80"
  },
})

vim.keymap.set('n', '<leader>t', function()
  neotest.run.run()
  neotest.output_panel.open()
end, { desc = 'Run the nearest test' })

vim.keymap.set('n', '<leader>r', function()
  neotest.run.run_last()
  neotest.output_panel.open()
end, { desc = 'Run last test' })

vim.keymap.set('n', '<leader>a', function()
  neotest.run.run(vim.fn.expand("%"))
  neotest.output_panel.open()
end, { desc = 'Run all tests in the file' })
