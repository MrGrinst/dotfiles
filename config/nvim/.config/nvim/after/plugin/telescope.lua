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

local function apply_file_grouping()
  vim.api.nvim_buf_set_option(0, 'filetype', 'telescope')
  local cmp = require('cmp')

  cmp.complete({
    config = {
      sources = {
        {
          name = 'luasnip',
        }
      }
    }
  })
end


local function close_unless_cmp_open(prompt_bufnr)
  local cmp = require('cmp')
  if not cmp.visible() then
    require('telescope.actions').close(prompt_bufnr)
  else
    cmp.close()
  end
end

local function cmp_or_select(prompt_bufnr)
  local cmp = require('cmp')
  if cmp.visible() then
    cmp.confirm({
      select = true,
    })
  else
    require('telescope.actions').toggle_selection(prompt_bufnr)
    require('telescope.actions').move_selection_worse(prompt_bufnr)
  end
end

local function cmp_down_or_down(prompt_bufnr)
  local cmp = require('cmp')
  if cmp.visible() then
    cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
  else
    require('telescope.actions').move_selection_next(prompt_bufnr)
  end
end

local function cmp_up_or_up(prompt_bufnr)
  local cmp = require('cmp')
  if cmp.visible() then
    cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
  else
    require('telescope.actions').move_selection_previous(prompt_bufnr)
  end
end

require('telescope').setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  },
  defaults = {
    sorting_strategy = "ascending",
    layout_config = {
      prompt_position = "top"
    },
    mappings = {
      i = {
        ["<Enter>"] = quickfix_multiple_or_drop_single,
        ["<esc>"] = close_unless_cmp_open,
        ["<tab>"] = cmp_or_select,
        ["<C-a>"] = require("telescope.actions").select_all,
        ["<down>"] = cmp_down_or_down,
        ["<up>"] = cmp_up_or_up,
        ["<C-t>"] = function(_) end,
        ["<C-f>"] = apply_file_grouping,
      },
      n = {
        ["<Esc>"] = require('telescope.actions').close,
        ["<Enter>"] = quickfix_multiple_or_drop_single,
        ["<C-t>"] = function(_) end,
        ["<C-f>"] = apply_file_grouping,
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
    initial_mode = 'normal',
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
vim.keymap.set('n', 'gU', require('telescope.builtin').lsp_references, { desc = '[U] Usages' })
