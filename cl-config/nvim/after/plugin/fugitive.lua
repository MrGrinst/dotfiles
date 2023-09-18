-- Map gb to see git blame
vim.keymap.set('n', 'gb', ':Git blame<cr>', { silent = true })

-- Map gD to see git diff
vim.keymap.set('n', 'gD', ':Gvdiffsplit HEAD~<cr>', { silent = true })

-- Map gh to see git status
vim.keymap.set('n', 'gS', ':Gedit :<cr>', { silent = true })

-- Add a way to start up vim and immediately show a diff
vim.api.nvim_create_user_command('Gvdiff', ':Git! difftool --name-only <q-args>', { nargs = '*' })
