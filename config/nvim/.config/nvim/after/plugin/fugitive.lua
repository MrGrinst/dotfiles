-- Map gb to see git blame
vim.keymap.set('n', 'gb', ':Git blame<cr>', { silent = true })

-- Map gD to see git diff
vim.keymap.set('n', 'gD', ':DiffviewFileHistory %<cr>', { silent = true })
