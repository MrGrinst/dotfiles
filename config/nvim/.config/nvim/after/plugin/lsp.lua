-- Enable the following language servers
local servers = {
  svelte = {},
  csharp_ls = {
    skip_mason = true,
    handlers = {
      ["textDocument/definition"] = require('csharpls_extended').handler,
      ["textDocument/typeDefinition"] = require('csharpls_extended').handler,
    },
  },
  html = {},
  jsonls = {},
  elixirls = { cmd = { "/Users/kylegrinstead/.local/share/nvim/mason/bin/elixir-ls" } },
  yamlls = {},
  syntax_tree = { skip_mason = true },
  solargraph = {},
  tailwindcss = {},
  ansiblels = {},
  bashls = {},
  lua_ls = {
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
  sourcekit = {
    skip_mason = true,
    capabilities = {
      workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      },
    },
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  },
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

  lsp_zero.buffer_autoformat()
end

lsp_zero.extend_lspconfig({
  sign_text = true,
  lsp_attach = lsp_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

require('mason').setup({})
require('mason-lspconfig').setup({
  -- all servers but filter out the skip_mason ones
  ensure_installed = vim.tbl_filter(function(server)
    return not server.skip_mason
  end, vim.tbl_map(function(server)
    return server.name
  end, servers)),

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

local null_ls = require('null-ls')

local cspell_config = {
  cspell_config_dirs = { "~/.config/" }
}

local cspell = require('cspell')
null_ls.setup({
  sources = {
    require("none-ls.diagnostics.eslint_d"),
    null_ls.builtins.formatting.swiftformat,
    cspell.diagnostics.with({ config = cspell_config }),
    cspell.code_actions.with({ config = cspell_config }),
    null_ls.builtins.formatting.prettierd.with({
      condition = function(utils)
        return utils.has_file({ "package.json" })
      end,
      filetypes = {
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "svelte",
        "typescript",
        "typescriptreact",
        "yaml",
      }
    }),
  },
  on_attach = lsp_zero.on_attach
})
