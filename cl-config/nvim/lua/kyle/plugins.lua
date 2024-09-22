-- Install Lazy.nvim package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
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
  -- Git plugin
  'tpope/vim-fugitive',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    'ray-x/sad.nvim',
    dependencies = { 'ray-x/guihua.lua', build = "cd lua/fzy && make" },
    config = function()
      require('sad').setup()
      vim.keymap.set('n', '<leader>S', ':Sad ', { desc = 'Find and replace in project' })
    end
  },

  {
    'stevearc/quicker.nvim',
    event = "FileType qf",
    opts = {},
  },

  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvimtools/none-ls-extras.nvim",
    },
  },

  'preservim/vim-markdown',

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      'nicholasmata/nvim-dap-cs',
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
  },

  {
    'wincent/scalpel',
    config = function()
      vim.keymap.set({ 'n', 'v' }, '<leader>s', '<Plug>(Scalpel)')
    end
  },

  {
    'stevearc/oil.nvim',
    dependencies = { "echasnovski/mini.icons" },
    config = function()
      require("oil").setup({
        keymaps = {
          ["<Esc>"] = "actions.close",
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

  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      notification = false,
      disabled_keys = {
        ["<Left>"] = {},
        ["<Right>"] = {},
        ["<Up>"] = {},
        ["<Down>"] = {},
      },
      restricted_keys = {
        ["<CR>"] = {},
      },
      hint = false
    }
  },

  -- Interact with files easily
  'tpope/vim-eunuch',

  -- Switch between source/test files
  {
    "tpope/vim-projectionist",
    config = function()
      vim.g.projectionist_heuristics = {
        ["Gemfile"] = {
          ["app/*.rb"] = {
            alternate = "spec/{}_spec.rb",
          },
          ["spec/*_spec.rb"] = {
            alternate = "app/{}.rb",
          },
        },
      }
      vim.keymap.set('n', '<leader>p', ':A<cr>', { silent = true })
    end,
    event = "User AstroFile",
  },

  -- Interact with tmux in various ways
  {
    'benmills/vimux',
    config = function()
      vim.g.VimuxOrientation = "h"
      vim.g.VimuxHeight = "40"

      vim.keymap.set('n', '<leader>v', function()
        if vim.fn.exists('g:VimuxLastCommand') ~= 0 and vim.g.VimuxLastCommand ~= '' then
          vim.fn.VimuxRunLastCommand()
        else
          vim.fn.VimuxPromptCommand()
        end
      end, { desc = 'Run or re-run command in tmux pane' })

      vim.keymap.set('n', '<leader>V', function()
        vim.fn.VimuxPromptCommand()
      end, { desc = 'Run new command in tmux pane' })
    end
  },

  -- Run and debug tests easily
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio', 'marilari88/neotest-vitest', 'olimorris/neotest-rspec', "antoinemadec/FixCursorHold.nvim",
    }
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
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
    -- <leader>w, etc to jump partway through a camel or snake case word
    'chaoren/vim-wordmotion',
    init = function()
      vim.g.wordmotion_prefix = '<Leader>'
    end
  },

  {
    -- LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },

      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
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
    -- Make virtual diagnostic only visible on current line unless ERROR
    'MrGrinst/lsp-virtual-improved.nvim',
    event = { 'LspAttach' },
    config = function()
      require('lsp-virtual-improved').setup()

      local diagnostics = {
        virtual_text = false,
        virtual_improved = {
          current_line = 'only',
          always_show_severity = vim.diagnostic.severity.ERROR
        },
      }
      vim.diagnostic.config(diagnostics)
    end,
  },

  {
    -- Automatically end pairs like [], {}, ()
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      require("nvim-autopairs").setup {}
      -- Automatically add `(` after selecting a function or method
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      local cmp = require('cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )
    end,
  },

  {
    -- Surround text with "ys", change with "cs" and delete with "ds"
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          visual = false,
        },
      })
    end
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      { 'L3MON4D3/LuaSnip', build = "make install_jsregexp" },
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
      }
    },
  },

  {
    "MrGrinst/parrot.nvim", dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  },

  {
    'ellisonleao/gruvbox.nvim',
    -- Gruvbox, the best theme
    priority = 1000,
    config = function()
      vim.o.background = 'dark'
      local palette = require('gruvbox').palette
      require('gruvbox').setup({
        overrides = {
          TabLine = { fg = palette.gray, bg = palette.bg2 },
          TabLineSel = { fg = palette.bg0, bg = palette.gray },
        }
      })
      vim.cmd.colorscheme 'gruvbox'
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'gruvbox',
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

  -- "gc" to comment visual regions/lines
  {
    'echasnovski/mini.comment',
    config = function()
      require('mini.comment').setup({
        mappings = {
          comment = '',
          comment_line = '',
          comment_visual = '',
          textobject = 'gC'
        },
      })
    end
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

  'tmux-plugins/vim-tmux-focus-events',

  {
    -- Substitue a portion of text without needing to visually select
    'gbprod/substitute.nvim',
    config = function()
      require("substitute").setup({})
      vim.keymap.set("n", "gr", require('substitute').operator, { noremap = true })
    end
  },
}, {})
