local neotest = require("neotest")

neotest.setup({
  adapters = {
    require("neotest-vitest"),
    require("neotest-rspec"),
  },
  output_panel = {
    enabled = true,
    open = "botright vsplit | vertical resize 80"
  },
  icons = {
    child_indent = "│",
    child_prefix = "├",
    collapsed = "─",
    expanded = "╮",
    failed = "x",
    final_child_indent = " ",
    final_child_prefix = "╰",
    non_collapsible = "─",
    passed = "✓",
    running = "…",
    running_animated = { "/", "|", "\\", "-", "/", "|", "\\", "-" },
    skipped = "s",
    unknown = "?",
    watching = "w"
  },
})

vim.keymap.set('n', '<leader>t', function()
  neotest.run.run()
  neotest.output_panel.open()
end, { desc = 'Run the nearest test' })

vim.keymap.set('n', '<leader>a', function()
  neotest.run.run(vim.fn.expand("%"))
  neotest.output_panel.open()
end, { desc = 'Run all tests in the file' })

local function GoToFile()
  local pos = vim.fn.getpos('.')
  local bufnr = vim.fn.bufnr(pos[2])
  local filename = vim.fn.bufname(bufnr)
  local line_number = pos[3]
  vim.cmd("wincmd h")
  vim.cmd("e " .. filename)
  vim.cmd("call cursor(" .. line_number .. ", 0)")
end

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    vim.keymap.set('n', '<CR>', GoToFile, { buffer = 0, noremap = true, silent = true })
  end,
  pattern = 'neotest-output-panel',
})
