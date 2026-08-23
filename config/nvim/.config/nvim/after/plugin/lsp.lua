local servers = {
  ansiblels = {},
  bashls = {},
  elixirls = {},
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
  svelte = {},
  tailwindcss = {},
  typos_lsp = {},
  yamlls = {},
}

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

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
})

require("typescript-tools").setup({
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

