-- Map gb to see git blame
vim.keymap.set('n', 'gb', ':Git blame<cr>', { silent = true })

-- Map gD to see git diff
vim.keymap.set('n', 'gD', ':DiffviewOpen HEAD -- %<cr>', { silent = true })

-- Map gH to see file history
vim.keymap.set('n', 'gH', ':DiffviewFileHistory %<cr>', { silent = true })
