-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local function quickfix_multiple_or_drop_single(prompt_bufnr)
  local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
  if #current_picker:get_multi_selection() == 0 then
    require('telescope.actions').select_default(prompt_bufnr)
  else
    require('telescope.actions').send_selected_to_qflist(prompt_bufnr)
    require('telescope.actions').open_qflist(prompt_bufnr)
    vim.cmd('cfirst')
  end
end

require('telescope').setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  },
  defaults = {
    mappings = {
      i = {
        ["<Enter>"] = quickfix_multiple_or_drop_single,
        ["<esc>"] = require('telescope.actions').close,
        ["<C-t>"] = function(_) end,
      },
      n = {
        ["<Esc>"] = require('telescope.actions').close,
        ["<Enter>"] = quickfix_multiple_or_drop_single,
        ["<C-t>"] = function(_) end,
      },
    },
  },
}

require("telescope").load_extension("ui-select")

local function grep_under_cursor(_)
  local word
  local visual = vim.fn.mode() == "v"

  if visual == true then
    local saved_reg = vim.fn.getreg("v")
    vim.cmd [[noautocmd sil norm "vy]]
    local sele = vim.fn.getreg("v")
    vim.fn.setreg("v", saved_reg)
    word = sele
  else
    word = vim.fn.expand("<cword>")
  end
  require("telescope.builtin").grep_string({ search = word })
  vim.defer_fn(function()
    vim.api.nvim_put({ word .. " " }, 'c', true, true)
  end, 50)
end

vim.keymap.set("n", "<C-d>", grep_under_cursor)
vim.keymap.set("v", "<C-d>", grep_under_cursor)

vim.keymap.set('n', '<C-t>', function()
  require('telescope.builtin').find_files({
    results_title = 'File Results',
    hidden = true
  })
end, {})

vim.keymap.set('n', '<C-f>', ':Grep<Space>', {})

vim.keymap.set('n', '<Enter>', function()
  require('telescope.builtin').buffers({
    sort_mru = true,
    ignore_current_buffer = true,
    file_ignore_patterns = { 'qf' },
    attach_mappings = function(_, map)
      map('n', '<c-w>', require('telescope.actions').delete_buffer)
      return true
    end,
  })
end, {})

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', '<enter>', '<enter>', { silent = true })
  end,
  pattern = 'qf',
})

vim.api.nvim_create_user_command('Grep',
  function(opts)
    if opts.fargs[1] ~= nil then
      require("telescope.builtin").grep_string(
        {
          search = opts.fargs[1],
          use_regex = true,
        }
      )
    else
      require("telescope.builtin").live_grep()
    end
  end,
  { nargs = '?' }
)

vim.keymap.set('n', '<m-5>',
  function()
    require('telescope.builtin').oldfiles({ only_cwd = true, hidden = true })
  end)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').help_tags, { desc = '[?] Search help' })
vim.keymap.set('n', '<leader>d', require('telescope.builtin').diagnostics, { desc = '[d] Search diagnostics' })
