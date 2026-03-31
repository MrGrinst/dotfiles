-- Install Lazy.nvim package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-fugitive',

  'tpope/vim-sleuth',

  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup({})
    end,
    keys = {
      { '<leader>S', ':GrugFar<cr>', { desc = 'Find and replace in project' } },
    },
  },

  { "meznaric/key-analyzer.nvim", opts = {} },

  'preservim/vim-markdown',

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
  },

  'nvim-telescope/telescope-ui-select.nvim',

  {
    'stevearc/oil.nvim',
    dependencies = {
      {
        "echasnovski/mini.icons",
        config = function()
          require('mini.icons').setup()
          MiniIcons.mock_nvim_web_devicons()
        end
      },
    },
    config = function()
      require("oil").setup({
        keymaps = {
          ["<Esc>"] = "actions.close",
          ["gs"] = function() require("oil").save({ confirm = true }) end
        },
        float = {
          padding = 10
        },
        view_options = {
          show_hidden = true,
        }
      })
      vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
    end
  },

  -- Interact with files easily
  'tpope/vim-eunuch',

  -- Interact with tmux in various ways
  {
    'benmills/vimux',
    config = function()
      vim.g.VimuxOrientation = "h"
      vim.g.VimuxHeight = "40"

      local function TelescopeCommandSelect()
        local sorter = require('telescope.sorters').get_substr_matcher()
        require('telescope.builtin').grep_string({
          prompt_title = "Command History",
          search = '',
          word_match = '-w',
          search_dirs = { vim.fn.expand("~/.zsh_history") },
          path_display = 'hidden',
          entry_maker = function(entry)
            local text = string.match(entry, "[^;]*;(.*)") or entry
            return {
              value = text,
              display = text,
              ordinal = text,
            }
          end,
          previewer = false,
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--max-columns=0",
            "--no-max-columns-preview",
            "--smart-case"
          },
          sorter = require('telescope.sorters').new({
            discard = false,
            scoring_function = function(_, prompt, line, entry)
              local base_score = sorter:scoring_function(prompt, line, entry)

              if base_score == -1 then
                return -1
              end

              return 999999999 - entry.index
            end,
            highlighter = sorter.highlighter,
          }),
          attach_mappings = function(_, map)
            map('i', '<CR>', function(prompt_bufnr)
              local selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(prompt_bufnr)
              if selection then
                vim.fn.VimuxRunCommand(selection.value)
              end
            end)
            return true
          end
        })
      end

      vim.keymap.set('n', '<leader><space>', function()
        if vim.fn.exists('g:VimuxLastCommand') ~= 0 and vim.g.VimuxLastCommand ~= '' then
          vim.fn.VimuxRunLastCommand()
        else
          TelescopeCommandSelect()
        end
      end, { desc = 'Run or re-run command in tmux pane' })

      vim.keymap.set('n', '<leader>V', function()
        TelescopeCommandSelect()
      end, { desc = 'Run new command in tmux pane' })
    end
  },

  -- Run and debug tests easily
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio', 'marilari88/neotest-vitest', 'olimorris/neotest-rspec', 'nvim-neotest/neotest-jest',
    }
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = { char = { enabled = false } }
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash"
      },
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<m-0>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<m-1>", "<cmd>TmuxNavigateDown<cr>" },
      { "<m-2>", "<cmd>TmuxNavigateUp<cr>" },
      { "<m-3>", "<cmd>TmuxNavigateRight<cr>" },
      { "<m-0>", "<cmd>TmuxNavigateLeft<cr>",  mode = "t" },
      { "<m-1>", "<cmd>TmuxNavigateDown<cr>",  mode = "t" },
      { "<m-2>", "<cmd>TmuxNavigateUp<cr>",    mode = "t" },
      { "<m-3>", "<cmd>TmuxNavigateRight<cr>", mode = "t" },
    },
  },

  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },

  {
    -- <leader>w, etc to jump partway through a camel or snake case word
    'chaoren/vim-wordmotion',
    init = function()
      vim.g.wordmotion_prefix = '<Leader>'
    end
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', config = true },
      'mason-org/mason-lspconfig.nvim',
    },
  },

  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  { 'echasnovski/mini.ai',        version = '*' },

  {
    'DanWlker/toolbox.nvim',
    config = function()
      require('toolbox').setup {
        commands = {
          --replace the bottom few with your own custom functions
          {
            name = 'LSP Info',
            execute = "LspInfo"
          },
          {
            name = 'LSP Log',
            execute = "LspLog"
          },
          {
            name = 'Key Analyzer',
            execute = ':KeyAnalyzer ',
            require_input = true
          },
          {
            name = 'Reload Neovim',
            execute = ':so ~/.config/nvim/init.lua',
          },
        },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>i', require('toolbox').show_picker, { desc = 'Toolbox' })
    end,
  },

  {
    "wojciech-kulik/xcodebuild.nvim",
    config = function()
      require("xcodebuild").setup({
        code_coverage = {
          enabled = true,
        },
      })

      vim.keymap.set("n", "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", { desc = "Build & Run Project" })
    end
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  {
    -- Automatically end pairs like [], {}, ()
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  {
    -- Surround text with "ys", change with "cs" and delete with "ds"
    "kylechui/nvim-surround",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_visual_mappings = true
    end,
    config = function()
      require("nvim-surround").setup()
    end
  },

  {
    'mg979/vim-visual-multi',
    init = function()
      vim.g.VM_maps = {
        ["Find Under"] = "<M-b>"
      }
      vim.g.VM_set_statusline = 3
    end,
  },

  {
    'nicolasgb/jj.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'folke/snacks.nvim',
      'esmuellert/codediff.nvim',
    },
    cmd = { 'J', 'Jj' },
    keys = {
      {
        '<leader>jd',
        function()
          require('jj.cmd').describe()
        end,
        desc = 'JJ describe',
      },
      {
        '<leader>jl',
        function()
          require('jj.cmd').log()
        end,
        desc = 'JJ log',
      },
      {
        '<leader>js',
        function()
          require('jj.cmd').status()
        end,
        desc = 'JJ status',
      },
      {
        '<leader>jj',
        function()
          require('jj.diff').show_revision({ rev = '@' })
        end,
        desc = 'JJ diff current change',
      },
      {
        '<leader>jn',
        function()
          require('jj.cmd').new()
        end,
        desc = 'JJ new',
      },
      {
        '<leader>jr',
        function()
          require('jj.cmd').rebase()
        end,
        desc = 'JJ rebase',
      },
      {
        '<leader>ja',
        function()
          require('jj.cmd').abandon()
        end,
        desc = 'JJ abandon',
      },
      {
        '<leader>ju',
        function()
          require('jj.cmd').undo()
        end,
        desc = 'JJ undo',
      },
      {
        '<leader>jp',
        function()
          require('jj.cmd').push()
        end,
        desc = 'JJ push',
      },
    },
    opts = {
      diff = {
        backend = 'codediff',
      },
      terminal = {
        cursor_render_delay = 10,
      },
      editor = {
        auto_insert = true,
      },
    },
  },

  {
    'esmuellert/codediff.nvim',
    cmd = 'CodeDiff',
    opts = {
      diff = {
        layout = 'side-by-side',
        jump_to_first_change = true,
        disable_inlay_hints = true,
      },
      explorer = {
        position = 'left',
        width = 40,
        initial_focus = 'explorer',
      },
      keymaps = {
        view = {
          toggle_explorer = '<leader>b',
          focus_explorer = '<leader>e',
          next_file = '<Tab>',
          prev_file = '<S-Tab>',
        }
      },
    },
    config = function(_, opts)
      require('codediff').setup(opts)
    end,
  },

  {
    'projekt0n/github-nvim-theme',
    name = 'github-theme',
    lazy = false,
    priority = 1000,
    config = function()
      local github_theme = vim.env.THEME
      if github_theme == 'github' then
        github_theme = vim.o.background == 'light' and 'github_light_default' or 'github_dark_default'
      end

      require('github-theme').setup({
        options = {
          module_default = true,
        },
      })

      if github_theme and github_theme:match('^github_') then
        vim.cmd.colorscheme(github_theme)
      end
    end,
  },

  { 'L3MON4D3/LuaSnip',                       build = "make install_jsregexp" },

  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      bind = true,
      floating_window = false,
    },
    config = function(_, opts) require 'lsp_signature'.setup(opts) end
  },

  {
    'mistweaverco/kulala.nvim',
    opts = {},
    config = function()
      require('kulala').setup {}
      vim.filetype.add({
        extension = {
          ['http'] = 'http',
        },
      })
      vim.keymap.set('n', '<leader>rr', require('kulala').run, { desc = 'Run HTTP Request' })
      vim.keymap.set('n', '<leader>rc', require('kulala').copy, { desc = 'Copy as cURL' })
      vim.keymap.set('n', '<leader>rt', require('kulala').toggle_view, { desc = 'Toggle View' })
    end
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  { 'roobert/tailwindcss-colorizer-cmp.nvim', opts = {} },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000,    -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup()
    end
  },

  {
    -- Adds git related signs to the gutter
    'lewis6991/gitsigns.nvim',
    opts = {
      base = 'HEAD',
      signs_staged_enable = false,
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        vim.keymap.set('n', ']c', function() gs.nav_hunk('next') end, { buffer = bufnr })
        vim.keymap.set('n', '[c', function() gs.nav_hunk('prev') end, { buffer = bufnr })
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, { buffer = bufnr })
        vim.keymap.set('n', '<leader>gs', gs.stage_hunk, { buffer = bufnr })
      end,
    },
  },


  {
    'ellisonleao/gruvbox.nvim',
    -- Gruvbox, the best theme
    priority = 1000,
    config = function()
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        overrides = {
          TabLine = { fg = palette.gray, bg = palette.bg2 },
          TabLineSel = { fg = palette.bg0, bg = palette.gray },
          CursorLine = { fg = palette.bg0 },
          DiffAdd = { bg = '#2e3425' },
          DiffChange = { bg = '#32302f' },
          DiffDelete = { bg = '#3c2a2a' },
          DiffText = { bg = '#4a4228', fg = '' },
          DiffviewDiffAddAsDelete = { bg = '#3c2a2a' },
          DiffviewDiffDelete = { fg = palette.bg4 },
        }
      })

      if not (vim.env.THEME and vim.env.THEME:match('^github')) then
        vim.o.background = 'dark'
        vim.cmd.colorscheme 'gruvbox'
      end
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      messages = { enabled = false },
      presets = { bottom_search = true },
      lsp = {
        signature = { enabled = false },
        progress = { enabled = false },
        message = { enabled = false },
      }
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    }
  },

  {
    'stevearc/conform.nvim',
    opts = {},
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },

  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = function()
          if vim.g.colors_name == 'github_light_default' then
            return 'github_light'
          end
          if vim.g.colors_name == 'github_dark_default' then
            return 'github_dark'
          end
          return 'gruvbox'
        end,
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'fileformat', 'filetype' },
        lualine_y = { 'location' },
        lualine_z = {}
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
      }
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {
      indent = {
        char = '┊',
      },
      whitespace = {
        remove_blankline_trail = true,
      },
      scope = { enabled = false },
    },
  },

  {
    'numToStr/Comment.nvim',
    opts = {}
  },

  {
    -- Fuzzy finder
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Change the case of text with <Leader>.
    "johmsalas/text-case.nvim",
    config = function()
      require('textcase').setup {}
      require('telescope').load_extension('textcase')
      vim.api.nvim_set_keymap('n', '<Leader>.', '<cmd>TextCaseOpenTelescope<CR>', { desc = "Telescope" })
      vim.api.nvim_set_keymap('v', '<Leader>.', "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
    end
  },

  {
    'windwp/nvim-ts-autotag',
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,         -- Auto close tags
          enable_rename = true,        -- Auto rename pairs of tags
          enable_close_on_slash = true -- Auto close on trailing </
        },
      })
    end
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      'RRethy/nvim-treesitter-endwise',
      'andymass/vim-matchup'
    },
    build = ':TSUpdate',
  },

  {
    -- Improved undo
    'mbbill/undotree',
    config = function()
      if vim.fn.has("persistent_undo") == 1 then
        local target_path = vim.fn.expand("~/.vim_undo_files")

        if vim.fn.isdirectory(target_path) == 0 then
          vim.fn.mkdir(target_path, "p")
        end

        vim.o.undodir = target_path
        vim.o.undofile = true
        vim.g.undotree_SetFocusWhenToggle = 1
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
      end
    end
  },

  {
    -- Substitute a portion of text without needing to visually select
    'gbprod/substitute.nvim',
    config = function()
      require("substitute").setup({})
      vim.keymap.set("n", "gr", require('substitute').operator, { noremap = true })
    end
  },
}, {})

local uv = vim.uv

vim.api.nvim_create_autocmd({ 'VimEnter', 'VimLeave' }, {
  callback = function()
    if vim.env.TMUX_PLUGIN_MANAGER_PATH then
      uv.spawn(vim.env.TMUX_PLUGIN_MANAGER_PATH .. '/tmux-window-name/scripts/rename_session_windows.py', {})
    end
  end,
})
