require("luasnip.session.snippet_collection").clear_snippets "cs"

local ls = require "luasnip"

local s = ls.snippet
local i = ls.insert_node

local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("cs", {
  s("pubf", fmt([[
    public {} {}({})
    {{
        {}
    }}
  ]], { i(1, "Return"), i(2, "Name"), i(3, "Args"), i(0) })),

  s("prif", fmt([[
    private {} {}({})
    {{
        {}
    }}
  ]], { i(1, "Return"), i(2, "Name"), i(3, "Args"), i(0) })),

  s("cl", fmt([[
    Console.WriteLine({});
  ]], { i(0) }))
})
