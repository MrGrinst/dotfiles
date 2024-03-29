-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local vmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('v', keys, func, { buffer = bufnr, desc = desc })
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

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
local servers = {
  tsserver = {},
  svelte = {},
  csharp_ls = { filetypes = { 'cs' } },
  html = { filetypes = { 'html' } },
  jsonls = {},
  yamlls = {},
  solargraph = {},
  tailwindcss = {},
  azure_pipelines_ls = {},
  ansiblels = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

vim.api.nvim_exec([[
  augroup DynamicLspInstall
    autocmd!
    autocmd BufRead,BufNewFile * lua SetupLspServers()
  augroup END
]], false)

function SetupLspServers()
  local current_filetype = vim.bo.filetype
  local ensure_servers = {}

  for server, config in pairs(servers) do
    local filetypes = config.filetypes or {}
    if (#filetypes == 0 or vim.tbl_contains(filetypes, current_filetype)) and server ~= 'csharp_ls' then
      table.insert(ensure_servers, server)
    end
  end

  mason_lspconfig.setup {
    ensure_installed = ensure_servers,
  }
end

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

require 'lspconfig'.syntax_tree.setup {}
require('lspconfig').csharp_ls.setup {
  capabilities = capabilities,
  on_attach = on_attach
}

local null_ls = require('null-ls')
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(buffer)
  vim.lsp.buf.format({
    filter = function(client)
      -- By default, ignore any formatters provider by other LSPs
      -- (such as those managed via lspconfig or mason)
      -- Also "eslint as a formatter" doesn't work :(
      return client.name == "null-ls" or client.name == "syntax_tree"
    end,
    bufnr = buffer,
  })
end

local on_attach = function(client, buffer)
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

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.eslint.with({
      "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte"
    }),
    null_ls.builtins.formatting.prettier.with({
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
  on_attach = on_attach
})

require('kyle.autoformat')
