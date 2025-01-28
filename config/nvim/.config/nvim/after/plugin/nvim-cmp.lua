-- [[ Configure nvim-cmp ]]
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

luasnip.filetype_set("all", {})

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-y>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.close()
      end
      cmp.complete({
        config = {
          sources = {
            { name = 'copilot' }
          }
        }
      })
      vim.defer_fn(function()
        cmp.complete({
          config = {
            sources = {
              { name = 'copilot' }
            }
          }
        })
      end, 1000)
    end),
    ['<CR>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        if luasnip.expandable() then
          luasnip.expand()
        else
          fallback()
        end
      else
        fallback()
      end
    end),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({
          select = true,
        })
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'codecompanion' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    {
      name = "lazydev",
      group_index = 0, -- set group index to 0 to skip loading LuaLS completions
    },
  },
  preselect = cmp.PreselectMode.None
}

local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

local file_groupings = {}

local json_file = io.open(".telescope-file-groupings.json", "r")
if json_file then
  local json_content = json_file:read("*all")
  json_file:close()
  file_groupings = vim.fn.json_decode(json_content)
end

local snippets = {}
for grouping, pattern in pairs(file_groupings) do
  table.insert(snippets, s(grouping, {
    t(pattern .. " "),
    i(1)
  }))
end

luasnip.add_snippets("telescope", snippets)

-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "[Prompt]",
--   callback = function()
--     vim.bo.filetype = "telescope"
--   end,
-- })

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})
