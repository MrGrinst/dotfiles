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
    capabilities = {
      workspace = {
        didChangeWatchedFiles = { dynamicRegistration = true },
      },
    },
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  },
  svelte = {},
  syntax_tree = {},
  tailwindcss = {},
  typos_lsp = {},
  yamlls = {},
}

local non_mason_servers = { 'sourcekit', 'syntax_tree' }

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local bufnr = event.buf

    local nmap = function(keys, func, desc)
      if desc then desc = 'LSP: ' .. desc end
      vim.keymap.set('n', keys, func, { desc = desc, buffer = bufnr })
    end

    local vmap = function(keys, func, desc)
      if desc then desc = 'LSP: ' .. desc end
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
  end,
})

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
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

vim.lsp.config('*', {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

for server_name, config in pairs(servers) do
  if next(config) ~= nil then
    vim.lsp.config(server_name, config)
  end
end

local mason_server_names = {}
local skip = {}
for _, name in ipairs(non_mason_servers) do skip[name] = true end
for server_name, _ in pairs(servers) do
  if not skip[server_name] then
    table.insert(mason_server_names, server_name)
  end
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = mason_server_names,
  automatic_enable = true,
})

for _, server_name in ipairs(non_mason_servers) do
  vim.lsp.enable(server_name)
end

require("typescript-tools").setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

