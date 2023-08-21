" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

" test nearest example
let test#strategy = "vimux"
nnoremap <silent><Leader>r :TestLast<CR>
nnoremap <silent><Leader>t :TestNearest<CR>
nnoremap <silent><Leader>a :TestFile<CR>
let test#elixir#exunit#options = '--trace'

let test#custom_runners = {
  \ 'javascript': ['JestIntegration', 'jest']
\ }

let g:coc_global_extensions = [
      \ 'coc-snippets',
      \ 'coc-spell-checker',
      \ ]

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif
