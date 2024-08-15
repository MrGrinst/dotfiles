require("parrot").setup {
  chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<M-y>" },
  providers = {
    anthropic = {
      api_key = os.getenv "ANTHROPIC_API_KEY",
    },
  },
  hooks = {
    CompleteCurrentBuffer = function(parrot, params)
      local template = [[
            I have the following code from {{filename}}:

            ```{{filetype}}
            {{filecontent}}
            ```

            Please look at the following section specifically:

            ```{{filetype}}
            {{selection}}
            ```

            Please rewrite just that section according to the contained instructions.
            Respond exclusively with the snippet that should replace that section.
            Please consider indentation level.
            Remove comments.
            DO NOT RETURN ANY EXPLANATION OR COMMENTS, ONLY RETURN CODE.
            DO NOT WRAP CODE IN BACKTICKS.
            ONLY RETURN CODE.
            ]]
      local model_obj = parrot.get_model("command")
      parrot.Prompt(params, parrot.ui.Target.rewrite, model_obj, nil, template)
    end,
    CompleteAllBuffers = function(parrot, params)
      local template = [[
            I have the following code from {{filename}} and other related files:

            ```{{filetype}}
            {{multifilecontent}}
            ```

            Please look at the following section specifically:

            ```{{filetype}}
            {{selection}}
            ```

            Please rewrite just that section according to the contained instructions.
            Respond exclusively with the snippet that should replace that section.
            Please consider indentation level.
            Remove comments.
            DO NOT RETURN ANY EXPLANATION OR COMMENTS, ONLY RETURN CODE.
            DO NOT WRAP CODE IN BACKTICKS.
            ONLY RETURN CODE.
            ]]
      local model_obj = parrot.get_model("command")
      parrot.Prompt(params, parrot.ui.Target.rewrite, model_obj, nil, template)
    end,
  }
}

vim.keymap.set('n', 'gpa', ":PrtAsk<Cr>", { desc = 'Ask AI a question' })
vim.keymap.set('n', 'gpc', ":PrtChatToggle<Cr>", { desc = 'Open chat' })
vim.keymap.set('v', 'gpc', ":PrtChatPaste<Cr>", { desc = 'Paste into chat' })
vim.keymap.set('n', 'gpf', ":PrtChatFind<Cr>", { desc = 'Find chat' })
vim.keymap.set('n', 'gpd', ":PrtChatDelete<Cr>", { desc = 'Find chat' })
vim.keymap.set('n', 'gpn', ":PrtChatNew<Cr>", { desc = 'New chat' })

vim.keymap.set('v', '<M-y>', ":<C-u>'<,'>PrtCompleteCurrentBuffer<Cr>", { desc = 'Complete the section' })
vim.keymap.set('i', '<M-y>', "<Esc><M-y>", { desc = 'Complete the section', remap = true })
vim.keymap.set('n', '<M-y>', "vgC<M-y>", { desc = 'Complete the section', remap = true })

vim.keymap.set('v', '<F18>', ":<C-u>'<,'>PrtCompleteAllBuffers<Cr>", { desc = 'Complete the section' })
vim.keymap.set('i', '<F18>', "<Esc><F18>", { desc = 'Complete the section', remap = true })
vim.keymap.set('n', '<F18>', "vgC<F18>", { desc = 'Complete the section', remap = true })
