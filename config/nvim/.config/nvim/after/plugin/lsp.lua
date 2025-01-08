-- Enable the following language servers
local servers = {
  ansiblels = {},
  bashls = {},
  elixirls = {
    cmd = { "/Users/kylegrinstead/.local/share/nvim/mason/bin/elixir-ls" }
  },
  eslint = {},
  html = {},
  jsonls = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
  solargraph = {},
  sourcekit = {
    skip_mason = true,
    capabilities = {
      workspace = {
        didChangeWatchedFiles = { dynamicRegistration = true, }, },
    },
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  },
  svelte = {},
  syntax_tree = { skip_mason = true },
  typos_lsp = {},
  yamlls = {},
}

local lsp_zero = require('lsp-zero')

local lsp_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { desc = desc, buffer = bufnr })
  end

  local vmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('v', keys, func, { desc = desc, buffer = bufnr })
  end

  nmap('gR', vim.lsp.buf.rename, 'Rename')
  vmap('gR', vim.lsp.buf.rename, 'Rename')
  nmap('gu', vim.lsp.buf.code_action, 'Code Action')
  vmap('gu', vim.lsp.buf.code_action, 'Code Action')
  nmap('gl', vim.lsp.buf.definition, 'Go to Definition')
  nmap('gL', function() vim.cmd('LspRestart') end, 'Restart LSP')
  nmap('gh', '<c-o>', 'Jump back')
  nmap('gm', vim.diagnostic.open_float, 'Open diagnostic message')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
end

local prettier_formatter = { "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
  formatters_by_ft = {
    svelte = prettier_formatter,
    typescriptreact = prettier_formatter,
    javascriptreact = prettier_formatter,
    typescript = prettier_formatter,
    javascript = prettier_formatter,
    json = prettier_formatter,
    html = prettier_formatter,
    yaml = prettier_formatter,
    markdown = prettier_formatter,
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- all servers but filter out the skip_mason ones
local mason_server_names = {}
for server_name, config in pairs(servers) do
  if not config.skip_mason then
    table.insert(mason_server_names, server_name)
  end
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = mason_server_names,
  handlers = {
    function(server_name)
      local server_config = servers[server_name] or {}
      if server_config.capabilities then
        server_config.capabilities = vim.tbl_deep_extend("force", lsp_zero.get_capabilities(), server_config
          .capabilities)
      end
      require('lspconfig')[server_name].setup(server_config)
    end,
  },
})

-- now setup the skip_mason ones since mason won't trigger the setup
for server_name, server_config in pairs(servers) do
  if server_config.skip_mason then
    if server_config.capabilities then
      server_config.capabilities = vim.tbl_deep_extend("force", lsp_zero.get_capabilities(), server_config.capabilities)
    end
    require('lspconfig')[server_name].setup(server_config)
  end
end

require("typescript-tools").setup({
  capabilities = lsp_zero.get_capabilities(),
})

require("tailwind-tools").setup({
  server = {
    on_attach = lsp_zero.on_attach
  }
})
