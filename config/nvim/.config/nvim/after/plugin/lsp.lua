local nmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set('n', keys, func, { desc = desc })
end

local vmap = function(keys, func, desc)
  if desc then
    desc = 'LSP: ' .. desc
  end

  vim.keymap.set('v', keys, func, { desc = desc })
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

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

-- Enable the following language servers
local servers = {
  { name = "svelte" },
  {
    skip_mason = true,
    name = "csharp_ls",
    capabilities = capabilities,
    handlers = {
      ["textDocument/definition"] = require('csharpls_extended').handler,
      ["textDocument/typeDefinition"] = require('csharpls_extended').handler,
    },
  },
  { name = "html" },
  { name = "jsonls" },
  { name = "elixirls",   cmd = { "/Users/kylegrinstead/.local/share/nvim/mason/bin/elixir-ls" } },
  { name = "yamlls" },
  { skip_mason = true,   name = "syntax_tree" },
  { name = "solargraph" },
  { name = "tailwindcss" },
  { name = "ansiblels" },
  { name = "bashls" },
  {
    name = "lua_ls",
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    }
  },
  {
    skip_mason = true,
    name = 'sourcekit',
    capabilities = vim.tbl_extend("force", capabilities, {
      workspace = {
        didChangeWatchedFiles = {
          dynamicRegistration = true,
        },
      },
    }),
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  },
}

vim.api.nvim_exec([[
  augroup DynamicLspInstall
    autocmd!
    autocmd BufRead,BufNewFile * lua SetupLspServers()
  augroup END
]], false)

function SetupLspServers()
  local ensure_servers = {}

  for _, config in ipairs(servers) do
    if not config.skip_mason then
      table.insert(ensure_servers, config.name)
    end
  end

  mason_lspconfig.setup {
    ensure_installed = ensure_servers,
  }

  for _, server in ipairs(servers) do
    if server.skip_mason then
      require('lspconfig')[server.name].setup {
        capabilities = capabilities,
        settings = server.settings,
        cmd = server.cmd,
        handlers = server.handlers,
      }
    end
  end
end

mason_lspconfig.setup_handlers {
  function(server_name)
    local servers_entry = vim.tbl_filter(function(entry) return entry.name == server_name end, servers)[1]
    if servers_entry then
      require('lspconfig')[servers_entry.name].setup {
        capabilities = capabilities,
        settings = servers_entry,
        cmd = servers_entry.cmd,
      }
    end
  end
}

local null_ls = require('null-ls')
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(buffer)
  vim.lsp.buf.format({
    filter = function(client)
      -- By default, ignore any formatters provider by other LSPs
      -- (such as those managed via lspconfig or mason)
      -- Also "eslint as a formatter" doesn't work :(
      return client.name == "null-ls" or client.name == "syntax_tree" or client.name == "elixirls"
    end,
    bufnr = buffer,
  })
end

local null_ls_on_attach = function(client, buffer)
  if (not buffer) then
    return
  end

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = buffer })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = buffer,
      callback = function()
        lsp_formatting(buffer)
      end,
    })
  end
end

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
  on_attach = null_ls_on_attach
})

require('kyle.autoformat')
