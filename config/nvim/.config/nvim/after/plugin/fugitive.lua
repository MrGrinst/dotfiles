-- Map gb to see git blame
vim.keymap.set('n', 'gb', ':Git blame<cr>', { silent = true })

-- Map gD to see git diff for the current file
vim.keymap.set('n', 'gD', ':CodeDiff file HEAD<cr>', { silent = true })

-- Map gH to see file history
vim.keymap.set('n', 'gH', ':CodeDiff history %<cr>', { silent = true })
vim.keymap.set('n', 'gdh', 'gH', { remap = true, silent = true, nowait = true })
