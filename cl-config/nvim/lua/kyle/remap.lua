-- [[ Basic Keymaps ]]

-- Disable space
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Use ; for commands.
vim.keymap.set("n", ";", ":")
vim.keymap.set("v", ";", ":")

-- Yank full line
vim.keymap.set("n", "Y", "yy")

vim.keymap.set("v", "Y", function()
    local start_line = math.min(vim.fn.line("v"), vim.fn.line("."))
    local end_line = math.max(vim.fn.line("v"), vim.fn.line("."))
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local min_indent = math.huge
    for _, line in ipairs(lines) do
        local indent = line:match("^%s*"):len()
        if indent < min_indent then
            min_indent = indent
        end
    end
    for i, line in ipairs(lines) do
        lines[i] = line:sub(min_indent + 1)
    end
    table.insert(lines, 1, "```")
    table.insert(lines, "```")
    local content = table.concat(lines, "\n")
    vim.fn.setreg("+", content)
    local esc = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)
end)

-- Yank til the end of the line (not including newline)
vim.keymap.set("n", "yy", "y$")

-- Prevent command history window from popping up
vim.keymap.set("n", "q:", "<Nop>")

-- Make escape hide highlights
vim.keymap.set('n', '<Esc>', '<Esc>:noh<CR>', { silent = true })
vim.keymap.set('i', '<Esc>', '<Esc>:noh<CR>', { silent = true })
vim.keymap.set('v', '<Esc>', '<Esc>:noh<CR>', { silent = true })

-- [[ FileType-based options ]]

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.api.nvim_buf_set_keymap(0, 'n', '<Esc>', ':bwipe<CR>', { silent = true })
    end,
    pattern = 'netrw',
})

-- Copy path of current file
vim.keymap.set('n', '<leader>c', function()
    vim.fn.setreg('+', vim.fn.expand('%'))
end, { silent = true })

-- Copy path and line of current file
vim.keymap.set('n', '<leader>C', function()
    vim.fn.setreg('+', vim.fn.expand('%') .. ':' .. vim.fn.line('.'))
end, { silent = true })

-- Copy link to the file (works for GitHub and Gitlab)
vim.keymap.set('n', '<leader>g', function()
    local base_url = vim.fn.system(
        'echo -n $(git remote get-url origin | sed -E "s/^.*?@(.*?):(.*?).git$/https:\\/\\/\\1\\/\\2\\/blob\\/master\\//")')
    local current_file = vim.fn.expand("%")
    vim.fn.setreg('+', base_url .. current_file .. '#L' .. vim.fn.line('.'))
end, { silent = true })

-- Automatically indent after pasting something containing newlines
vim.keymap.set('n', 'p', 'getreg(\'"\') =~ "\n" ? "p=`]" : getline(".") =~ "^$" ? "p=`]" : "p"',
    { silent = true, expr = true })
vim.keymap.set('v', 'p', 'getreg(\'"\') =~ "\n" ? "p=`]" : getline(".") =~ "^$" ? "p=`]" : "p"',
    { silent = true, expr = true })

-- Cycle through quickfix list
vim.keymap.set('n', '<down>', ':cn<cr>', { silent = true })
vim.keymap.set('n', '<up>', ':cp<cr>', { silent = true })

-- Make left and right go through the jumplist
vim.keymap.set('n', '<left>', '<C-o>', { silent = true })
vim.keymap.set('n', '<right>', '<C-i>', { silent = true })

-- Improved scrolling
vim.keymap.set('n', 'm', 'm\'<C-d>zz', { silent = true })
vim.keymap.set('n', ',', 'm\'<C-u>zz', { silent = true })
vim.keymap.set('v', 'm', '<C-d>zz', { silent = true })
vim.keymap.set('v', ',', '<C-u>zz', { silent = true })

-- Improved next/prev search
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })

-- Map U to redo
vim.keymap.set('n', 'U', '<C-r>')

-- Stop <C-z> from suspending
vim.keymap.set('n', '<C-z>', '<Nop>')

-- Tab to indent code
vim.keymap.set('n', '<Tab>', '>>')
vim.keymap.set('n', '<M-`>', '<<')
vim.keymap.set('v', '<Tab>', '>gv')
vim.keymap.set('v', '<M-`>', '<gv')
vim.keymap.set('n', '<', '<Nop>')
vim.keymap.set('v', '<', '<Nop>')
vim.keymap.set('n', '>', '<Nop>')
vim.keymap.set('v', '>', '<Nop>')

-- Consistent menu navigation
vim.keymap.set('i', '<C-j>', '<C-n>')
vim.keymap.set('i', '<C-k>', '<C-p>')

-- Enable alt-left, alt-right, and alt-backspace for command mode
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-right>')
vim.keymap.set('c', '<A-BS>', '<C-w>')

-- Save current file
vim.keymap.set('n', 'gs', ':w<cr>')

-- Move quickly between vim panes
local function navigate_or_split(direction)
    return function()
        local cmd
        if direction == "up" then
            cmd = "wincmd k"
        elseif direction == "down" then
            cmd = "wincmd j"
        elseif direction == "left" then
            cmd = "wincmd h"
        elseif direction == "right" then
            cmd = "wincmd l"
        else
            return
        end

        local current_win = vim.fn.win_getid()
        vim.cmd(cmd)
        if vim.fn.win_getid() == current_win then
            if direction == "down" then
                vim.cmd("new")
            elseif direction == "right" then
                vim.cmd("vnew")
            end
        end
    end
end

-- Don't copy empty lines
local function smart_dd()
    if vim.api.nvim_get_current_line():match("^%s*$") then
        return '"_dd'
    else
        return "dd"
    end
end

vim.keymap.set("n", "dd", smart_dd, { noremap = true, expr = true })

-- Allow excecuting . or macros on selection
vim.keymap.set("x", ".", ":norm .<CR>", { noremap = true, silent = true })
vim.keymap.set("x", "@", ":norm @q<CR>", { noremap = true, silent = true })

-- Make navigating between windows easy
vim.keymap.set('n', '<leader>h', navigate_or_split('left'), { silent = true })
vim.keymap.set('n', '<leader>k', navigate_or_split('up'), { silent = true })
vim.keymap.set('n', '<leader>j', navigate_or_split('down'), { silent = true })
vim.keymap.set('n', '<leader>l', navigate_or_split('right'), { silent = true })

-- Make window wider/less wide, taller/less tall
vim.keymap.set('n', '<leader>H', '<C-w>10>', { silent = true })
vim.keymap.set('n', '<leader>L', '<C-w>10<', { silent = true })
vim.keymap.set('n', '<leader>K', '<C-w>10+', { silent = true })
vim.keymap.set('n', '<leader>J', '<C-w>10-', { silent = true })

-- New buffer with <c-n>
vim.keymap.set('n', '<M-b>', ':enew<cr>')

-- Make A indent correctly for blank lines
vim.keymap.set('n', 'A', 'getline(line(".")) =~ "^$" ? "cc" : "A"', { expr = true })

-- Change line order
vim.keymap.set('n', '<M-7>', ':m .+1<CR>==')
vim.keymap.set('n', '<M-8>', ':m .-2<CR>==')
vim.keymap.set('v', '<M-7>', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', '<M-8>', ':m \'<-2<CR>gv=gv')

-- Double tap v to visually select box
vim.keymap.set('v', 'v', '<C-v>')

vim.keymap.set('n', '<M-6>', '<Nop>')

-- Close window
vim.keymap.set('n', '<C-w>', ':q<CR>', { silent = true })

-- Cmd-/ to comment line(s)
vim.keymap.set('v', '<M-4>', 'gc', { remap = true })
vim.keymap.set('n', '<M-4>', 'gcc', { remap = true })

-- Delete current file (but allow undoing)
vim.keymap.set('n', '<leader>q', function()
    vim.cmd('Remove')
end, { desc = 'Delete current file' })
