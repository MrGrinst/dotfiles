local codediff_refresh_group = vim.api.nvim_create_augroup('KyleCodeDiffRefresh', { clear = true })

local function refresh_codediff_tab(tabpage)
  local lifecycle = require('codediff.ui.lifecycle')
  local session = lifecycle.get_session(tabpage)
  if not session then
    return
  end

  if session.mode == 'explorer' then
    local explorer = lifecycle.get_explorer(tabpage)
    if explorer then
      require('codediff.ui.explorer.refresh').refresh(explorer)
    end
    return
  end

  if session.mode == 'history' then
    local history = lifecycle.get_explorer(tabpage)
    if history then
      require('codediff.ui.history.refresh').refresh(history)
    end
    return
  end

  require('codediff.ui.view').update(tabpage, {
    mode = session.mode,
    git_root = session.git_root,
    original_path = session.original_path,
    modified_path = session.modified_path,
    original_revision = session.original_revision,
    modified_revision = session.modified_revision,
  }, false)
end

vim.api.nvim_create_autocmd('User', {
  group = codediff_refresh_group,
  pattern = 'CodeDiffOpen',
  callback = function()
    local tabpage = vim.api.nvim_get_current_tabpage()
    require('codediff.ui.lifecycle').set_tab_keymap(tabpage, 'n', 'r', function()
      refresh_codediff_tab(tabpage)
    end, {
      desc = 'Refresh codediff',
      nowait = true,
    })
  end,
})
