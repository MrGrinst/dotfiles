-- [[ Configure Treesitter ]]
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'bash',
    'c_sharp',
    'css',
    'elixir',
    'html',
    'javascript',
    'json',
    'markdown',
    'lua',
    'python',
    'ruby',
    'svelte',
    'swift',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
  },

  endwise = { enable = true },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'S',
      scope_incremental = '-',
      node_incremental = 'S',
      node_decremental = 'A',
    },
  },
  matchup = { enable = true },
}
