-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- [[ Configure Telescope ]]

local function quickfix_multiple_or_drop_single(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	if #current_picker:get_multi_selection() == 0 then
		require('telescope.actions').select_default(prompt_bufnr)
	else
		require('telescope.actions').add_selected_to_qflist(prompt_bufnr)
		require('telescope.actions').open_qflist(prompt_bufnr)
	end
end

local function maybe_close_or_normal_mode(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	if current_picker.results_title == 'File Results' then
		require('telescope.actions').close(prompt_bufnr)
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
	end
end

require('telescope').setup {
	defaults = {
		file_ignore_patterns = { ".git/" },
		mappings = {
			i = {
				["<Enter>"] = quickfix_multiple_or_drop_single,
				["<esc>"] = maybe_close_or_normal_mode
			},
			n = {
				["<Esc>"] = require('telescope.actions').close,
				["<Enter>"] = quickfix_multiple_or_drop_single
			},
		},
	},
}

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
		results_title = 'File Results'
	})
end, {})

vim.keymap.set('n', '<C-f>', ':Grep<Space>', {})

vim.keymap.set('n', '<Enter>', function()
	require('telescope.builtin').buffers({
		sort_mru = true,
		ignore_current_buffer = true,
		file_ignore_patterns = { 'qf' },
		initial_mode = 'normal'
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
				{ search = opts.fargs[1], use_regex = true }
			)
			vim.defer_fn(function()
				vim.api.nvim_put({ opts.fargs[1] .. " " }, 'c', true, true)
			end, 50)
		else
			require("telescope.builtin").live_grep()
		end
	end,
	{ nargs = '?' }
)

vim.keymap.set('n', '<m-5>', require('telescope.builtin').oldfiles)
vim.keymap.set('n', '<leader>?', require('telescope.builtin').help_tags, { desc = '[?] Search help' })
