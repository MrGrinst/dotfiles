-- Map gb to see git blame
vim.keymap.set('n', 'gb', ':Git blame<cr>', { silent = true })

-- Map gD to see git diff
vim.keymap.set('n', 'gD', ':Gvdiffsplit HEAD~<cr>', { silent = true })

-- Map gh to see git status
vim.keymap.set('n', 'gS', ':Gedit :<cr>', { silent = true })
