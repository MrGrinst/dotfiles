-- [[ Configure Treesitter ]]
-- Highlighting, folds and injections come from Neovim core; this plugin only
-- installs parsers and queries, so features are wired up per-buffer below.
local ts = require('nvim-treesitter')

ts.setup {}

local ensure_installed = {
  'bash',
  'css',
  'elixir',
  'html',
  'javascript',
  'json',
  'markdown',
  'lua',
  'python',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

ts.install(ensure_installed)

local installable = {}
for _, lang in ipairs(ts.get_available()) do
  installable[lang] = true
end

local function enable(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match)
    if not lang then
      return
    end

    if vim.list_contains(ts.get_installed(), lang) then
      enable(ev.buf, lang)
    elseif installable[lang] then
      ts.install(lang):await(vim.schedule_wrap(function(err)
        if not err then
          enable(ev.buf, lang)
        end
      end))
    end
  end,
})
