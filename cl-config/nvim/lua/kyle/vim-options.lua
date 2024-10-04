-- [[ Setting options ]]
--

-- Hide banner in netrw
vim.g.netrw_banner = 0

-- Allow 2 lines for commands
vim.o.cmdheight = 2

-- Make line numbers default
vim.wo.number = true

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Don't show the intro message when starting Vim
vim.o.shortmess = "aIW"

-- Convert tab to spaces
vim.o.expandtab = true

-- the visible width of tabs
vim.o.tabstop = 4

-- edit as if the tabs are 4 characters wide
vim.o.softtabstop = 4

-- Default to a good text width
vim.o.textwidth = 120

-- number of spaces to use for indent and unindent
vim.o.shiftwidth = 4

-- round indent to a multiple of 'shiftwidth'
vim.o.shiftround = true

-- Prevent auto-commenting lines when using 'o' or 'O' on a comment line
vim.opt.formatoptions:remove('o')

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Horizontal split below current
vim.o.splitbelow = true

-- Vertical split to right of current
vim.o.splitright = true

-- Confirm some actions instead of just failing
vim.o.confirm = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Modern colors
vim.o.termguicolors = true

-- No need for swap files
vim.o.swapfile = false

-- Allow UNIX and DOS line endings (though prefer UNIX)
vim.o.fileformats = 'unix,dos'

-- Have a reasonable number of context at the top when scrolling up
vim.o.scrolloff = 5
vim.o.sidescrolloff = 5

-- Save lots of command history
vim.o.history = 1000

-- Set ripgrep as the default grep (just in case it's ever used)
vim.o.grepprg = 'rg'

-- Always do find/replace on the whole file
vim.o.gdefault = true

-- Disable code folding
vim.o.foldenable = false

-- Always show the sign column so buffers don't jump around
vim.o.signcolumn = 'yes'

-- Show invisible characters
vim.o.listchars = "tab:> ,trail:·,nbsp:+"
vim.opt.list = true

-- Delete buffers when they aren't showing
vim.o.bufhidden = 'delete'

-- [[ FileType-based options ]]

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.o.textwidth = 100
        vim.o.colorcolumn = '100'
    end,
    pattern = 'gitcommit',
})

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.bo[vim.api.nvim_get_current_buf()].buflisted = false
    end,
    pattern = 'qf',
})

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.api.nvim_exec([[
            autocmd BufWritePre * silent normal! gqq
        ]], false)
    end,
    pattern = 'cs',
})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

-- [[ Strip trailing spaces ]]
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*" },
    callback = function()
        vim.cmd([[%s/\s\+$//e]])
    end
})

local misc_augroup = vim.api.nvim_create_augroup('MiscAugroup', { clear = true })
vim.api.nvim_create_autocmd('BufReadPost', {
    desc = 'Open file at the last position it was edited earlier',
    group = misc_augroup,
    pattern = '*',
    command = 'silent! normal! g`"zv'
})
