"""""""""""""""""""""""""
"""""""""""""""""""""""""
"" PLUGIN INSTALLATION ""
"""""""""""""""""""""""""
"""""""""""""""""""""""""

" install vim-plug if not already installed
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source ~/.config/nvim/init.vim
endif

let g:polyglot_disabled = ['autoindent']

filetype off
call plug#begin()
Plug 'tpope/vim-surround'                                                         " easily surround objects with things like {, [, (, etc
Plug 'tpope/vim-fugitive'                                                         " great git integration
Plug 'tpope/vim-commentary'                                                       " nice commenting using commands
Plug 'tpope/vim-sleuth'                                                           " matches indentation style to the current file
Plug 'tpope/vim-repeat'                                                           " allows the . operator to be used for other plugins
Plug 'fatih/vim-go'                                                               " go!
Plug 'sheerun/vim-polyglot'                                                       " better support for many programming languages
Plug 'editorconfig/editorconfig-vim'                                              " allows use of .editorconfig file
Plug '/usr/local/opt/fzf'                                                         " fuzzy finder for opening files and some completions
Plug 'junegunn/fzf.vim'                                                           " set defaults for the fuzzy finder
Plug 'alvan/vim-closetag'                                                         " better XML editing, mainly adding the ability to auto-close tags
Plug 'tpope/vim-endwise'                                                          " gives better support for ruby blocks
Plug 'tmux-plugins/vim-tmux-focus-events'                                         " gives support for knowing when focus is gained and lost (allows file reloading)
Plug 'benmills/vimux'                                                             " allows running commands in tmux easily
Plug 'vim-scripts/ReplaceWithRegister'                                            " make pasting over text nicer
Plug 'chaoren/vim-wordmotion'                                                     " make motion better
Plug 'morhetz/gruvbox'                                                            " awesome theme
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }                                  " clojure REPL
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }                              " make clojure development great again
Plug 'kien/rainbow_parentheses.vim'                                               " colors!
Plug 'clojure-vim/async-clj-omni', { 'for': 'clojure' }                           " clojure stuff
Plug 'bhurlow/vim-parinfer', { 'for': 'clojure' }                                 " parentheses balancing
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': { -> coc#util#install() }}  " fantastic IDE-like tools
Plug 'brooth/far.vim'                                                             " find-and-replace
Plug 'dunckr/js_alternate.vim'                                                    " switch between src/test js files
Plug 'guns/vim-sexp',    {'for': 'clojure'}                                       " clojurey stuff
Plug 'liquidz/vim-iced', {'for': 'clojure'}                                       " clojurey stuff
Plug 'liquidz/vim-iced-coc-source', {'for': 'clojure'}                            " clojure + coc
call plug#end()
filetype plugin indent on

""""""""""""""""""""""
""""""""""""""""""""""
"" GENERAL SETTINGS ""
""""""""""""""""""""""
""""""""""""""""""""""

let g:python3_host_prog = '~/.pyenv/shims/python3'

" track undo history even after closing vim. Note: the directory must already be
" created
set undofile
set undodir=~/.vim_undo_files

set noswapfile

" strip trailing whitespace on save
let strip_whitespace_blacklist = ['sql']
autocmd BufWritePre * if index(strip_whitespace_blacklist, &ft) < 0 | %s/\s\+$//e | endif

if has('mouse')
  set mouse=a
endif

" ensure the autocomplete menu closes when I'm done with it
autocmd FocusLost * set nolazyredraw
autocmd FocusGained * set lazyredraw

" faster redrawing
set ttyfast
" not compatible with vi
set nocompatible
" detect when a file is changed
set autoread
" make backspace behave in a sane manner
set backspace=indent,eol,start

if !&scrolloff
  set scrolloff=3
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline
set signcolumn=yes

au FileType * setlocal textwidth=0
" delete comment character when joining commented lines
au FileType * setlocal formatoptions+=j
" add comment to next line when hitting Enter on comment line
au FileType * setlocal formatoptions+=r
" prevent auto-commenting lines when using 'o' or 'O' on a comment line
au FileType * setlocal formatoptions-=o
" prevent auto-wrapping of text
au FileType * setlocal formatoptions-=t
" prevent auto-wrapping of lines with comments
au FileType * setlocal formatoptions-=c

au filetype crontab setlocal nobackup nowritebackup

if &history < 1000
  set history = 1000
endif
if &tabpagemax < 50
  set tabpagemax = 50
endif
if !empty(&viminfo)
  set viminfo^=!
endif

" delete buffers when they're no longer shown
set bufhidden=delete

"""""""""""""""""
"""""""""""""""""
"" INDENTATION ""
"""""""""""""""""
"""""""""""""""""

set expandtab
" tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set smarttab
" the visible width of tabs
set tabstop=4
" edit as if the tabs are 4 characters wide
set softtabstop=4
" number of spaces to use for indent and unindent
set shiftwidth=4
" round indent to a multiple of 'shiftwidth'
set shiftround
" automatically set indent of new line
set autoindent
set smartindent
setlocal indentkeys+=0.

set completeopt+=longest
set completeopt+=menuone
set completeopt+=preview

" make vim use the clipboard for copying/pasting
set clipboard=unnamed

autocmd Filetype go setlocal tabstop=2 shiftwidth=2 softtabstop=2

""""""""""""""""""""
""""""""""""""""""""
"" USER INTERFACE ""
""""""""""""""""""""
""""""""""""""""""""

" don't show the intro message when starting Vim
set shortmess=atI
" searching
" case insensitive searching
set ignorecase
" case-sensitive if expression contains a capital letter
set smartcase
" highlight search results
set hlsearch
" set incremental search, like modern browsers
set incsearch
" use ripgrep
set grepprg=rg\ -SL
" don't redraw while executing macros
set lazyredraw
" use 'g' flag by default with :s/foo/bar/.
set gdefault
" don't show matching parens
let g:loaded_matchparen = 1

" say no to code folding...
set nofoldenable

" set magic on, for regex
set magic
" no color column by default
set colorcolumn=

" how many tenths of a second to blink
set mat=2
" show all text past column as an error
let highlight_long_lines_blacklist = ['fzf']
autocmd FileType * if index(highlight_long_lines_blacklist, &ft) < 0 | let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1) | endif
" set a color column for commit messages
au FileType gitcommit setlocal colorcolumn=72
au FileType gitcommit setlocal textwidth=72

" toggle invisible characters
set list
set listchars=tab:→→,trail:⋅,extends:❯,precedes:❮
autocmd Filetype go setlocal list&
autocmd Filetype go setlocal listchars=trail:⋅,extends:❯,precedes:❮
" make the highlighting of tabs and other non-text less annoying
highlight SpecialKey ctermbg=none ctermfg=8
highlight NonText ctermbg=none ctermfg=8

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

let &titlestring=@%
set title

" no beeps.
set noerrorbells visualbell t_vb=

set showtabline=2
set laststatus=2
set statusline=
set statusline+=%F\                          " filename
set statusline+=%h%m%r%w                     " status flags
set statusline+=%=                           " right align remainder
set statusline+=%y                           " file type

set tabline=%!ImprovedTabline()

" more natural splits
" horizontal split below current.
set splitbelow
" vertical split to right of current.
set splitright
set switchbuf+=usetab,newtab


""""""""""""""""""
""""""""""""""""""
"" THEME/COLORS ""
""""""""""""""""""
""""""""""""""""""

" WARNING: DO NOT CHANGE ORDER OR THEME WILL NOT WORK
" switch syntax highlighting on
syntax on
" set the encoding
set encoding=utf8
" obviously need a dark background!
set background=dark
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark='medium'
let g:gruvbox_termcolors=16
" set the color scheme to gruvbox. Silent means it won't fail the first time we start vim
silent! colorscheme gruvbox
" use normal line number for the selected line
set number
set timeout
set timeoutlen=350
" ensure there is no delay when escaping from insert mode
set ttimeout
" ensure there is no delay when escaping from insert mode
set ttimeoutlen=1
highlight ErrorMsg ctermbg=none ctermfg=none cterm=underline
" make comments italic
highlight Comment cterm=italic

highlight TabLineFill ctermfg=none ctermbg=none cterm=none
highlight TabLine ctermfg=LightGray ctermbg=239 cterm=none
highlight TabLineSel ctermfg=Black ctermbg=LightGray cterm=none
highlight TabLineChanged ctermfg=Black ctermbg=Blue cterm=none


""""""""""""""
""""""""""""""
"" MAPPINGS ""
""""""""""""""
""""""""""""""

"""""""""""""""
" Normal Mode "
"""""""""""""""

" make movement work regardless of line wrapping
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$

" prevent <C-z> from suspending
nnoremap <C-z> <nop>

nnoremap <M-,> :silent cp<CR>
nnoremap <M-.> :silent cn<CR>

" automatically indent after pasting something containing newlines
nnoremap <silent><expr> p getreg('""') =~ '\n' ? "p=`]" : getline(".") =~ '^$' ? "p=`]" : "p"
vnoremap <silent><expr> p getreg('""') =~ '\n' ? "p=`]" : getline(".") =~ '^$' ? "p=`]" : "p"

" map <C-[> to go back in file stack (requires iTerm2 mapping)
nnoremap <M-=> <C-o>

" jump to the definition using CoC
nnoremap <C-]> :call CocAction('jumpDefinition')<CR>

" find references of the current word
nnoremap <C-u> :call CocAction('jumpReferences')<CR>

" search for text in project
nnoremap <silent> <expr> <M-^> ":Rg " . GetWordUnderCursor() . "\\W\<CR>"

" show the documentation for the current function
nnoremap <silent> K :call <SID>show_documentation()<CR>

" map U to redo
nnoremap U <C-r>

" map gb to :Gblame
nnoremap <silent> gb :Gblame<CR>

" map gd to :Gdiff
nnoremap <silent> gd :Gdiff HEAD~<CR>
" map gh to :BCommits
nnoremap <silent> gh :BCommits<CR>

" use Q to execute default macro
nnoremap <silent> Q @q

" move between tabs
tnoremap <silent> <Left> <C-\><C-n>:tabp<CR>
tnoremap <silent> <Right> <C-\><C-n>:tabn<CR>
nnoremap <silent> <Left> :tabp<CR>
nnoremap <silent> <Right> :tabn<CR>

" move tabs around
nnoremap <silent> <M-b> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <M-f> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

" cmd-shift-f to find text in files matching a glob
nnoremap <M-@> :RgGlob<Space>

" cmd-shift-r to find and replace in the current directory
nnoremap <M-%> :Far<Space>

" make search better
nnoremap * /\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap # ?\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap n nzz
nnoremap N Nzz

" yank til the end of the line
nnoremap yy y$

" double cmd-/ to comment out the current line and paste below
vmap <C-_><C-_> y'>pgvgc'>j
nmap <C-_><C-_> Ypkgccj

" make escape hide highlights
nnoremap <silent> <Esc> <Esc>:noh<CR>
inoremap <silent> <Esc> <Esc>:noh<CR>
vnoremap <silent> <Esc> <Esc>:noh<CR>

" cmd-s to save
nnoremap <C-s> :w<CR>

" cmd-t to fuzzy search all files in the current directory
nnoremap <C-t> :Files!<CR>

" cmd-f to search for text in the current directory
nnoremap <C-f> :Rg<Space>

" stops the command history window from popping up
nnoremap q: <nop>

" use ; for commands.
nnoremap ; :
vnoremap ; :
" so I actually learn the ; mapping
nnoremap : <nop>
vnoremap : <nop>

" stop space from doing anything
nnoremap <Space> <nop>

" better scrolling
nnoremap <Down> <C-d>
nnoremap <Up>   <C-u>
vnoremap <Down> <C-d>
vnoremap <Up>   <C-u>

" cmd-r to save and re-run the last command in the other tmux pane
nnoremap <silent> <C-r> :w <Bar> call VimuxOpenRunner() <Bar> call VimuxSendKeys("C-c Up Enter")<CR>

" cmd-n to open a new file like most modern editors
nnoremap <C-n> :tabe<CR>

" cmd-x to close a tab like most modern editors
nnoremap <C-x> :call CloseTab()<CR>

" closed tab history. reopen with Cmd-Shift-T
nnoremap <silent> <M-t> :call ReopenLastTab()<CR>

" cmd-/ to comment line(s)
vmap <C-_> gc
nmap <C-_> gcc

" change indentation with tab/shift-tab
nnoremap <Tab> >>
nnoremap <M-`> <<
vnoremap <Tab> >
vnoremap <M-`> <

" change line order
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" make A indent correctly for blank lines
nnoremap <expr> A getline(line(".")) =~ "^$" ? "cc" : "A"

" make o/O work with endwise
nmap <expr> o getline(line(".") + 1) =~ "^$" ? "A<CR>" : "o"
nmap <expr> O getline(line(".")) =~ "^$" ? "kA<CR>" : "O"

"""""""""""""""
" Insert Mode "
"""""""""""""""

" consistent menu navigation
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>

inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi

" enable alt-backspace
imap <A-BS> <C-W>

" enable command-backspace (requires iTerm2 mapping)
imap <A-?> <C-u>

" enable alt-Left and alt-Right in insert mode
inoremap <M-b> <C-o>b
inoremap <M-f> <C-o>w

""""""""""""""""
" Command Mode "
""""""""""""""""

" enable alt-left, alt-right, and alt-backspace
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-right>
cnoremap <A-BS> <C-w>


"""""""""""""""""""""
"""""""""""""""""""""
"" LEADER MAPPINGS ""
"""""""""""""""""""""
"""""""""""""""""""""

" set leader key to <Space>
let mapleader=' '

" copy path of current file
nnoremap <silent><Leader>c :let @+ = expand("%")<CR>

" copy path and line of current file
nnoremap <silent><Leader>C :let @+ = expand("%") . ':' . line('.')<CR>

" copy the link to Gitiles
nnoremap <silent><Leader>g :call CopyGitilesLink()<CR>

" refactor (rename) the current word
nnoremap <Leader>r <Plug>(coc-refactor)

" rename the current file
nnoremap <silent><Leader>n :CocCommand workspace.renameCurrentFile<CR>

" cmd-e to open file explorer
nnoremap <C-e> :CocCommand explorer<CR>

" duplicate the current file into another tab
nnoremap <Leader>d :call DuplicateFile()<CR>

" search and replace in the current file
nnoremap <Leader>s :%s//<Left>

" switch between a source file and test file (Rails/React)
nnoremap <silent><Leader>p :call SwitchBetweenSourceAndTest()<CR>
au FileType javascript,jsx,typescript,json,typescriptreact nnoremap <silent><Leader>p :call JsAlternateRun()<CR>

" open a new tab with Git status
nnoremap <silent><Leader>- :Gtabedit :<CR>


"""""""""""""""""""""
"""""""""""""""""""""
"" PLUGIN SETTINGS ""
"""""""""""""""""""""
"""""""""""""""""""""

"""""""
" FZF "
"""""""

" hide statusline of terminal buffer
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
                   \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
                   \| autocmd BufEnter <buffer> set laststatus=0 noshowmode noruler | startinsert

command! -nargs=* Rg call fzf#vim#grep("rg --follow --column --line-number --no-heading --color=always --smart-case " . shellescape(<q-args>) . " || :", 1, fzf#vim#with_preview('right:50%'), 1)
command! -nargs=* RgGlob call fzf#vim#grep("rg --follow --column --line-number --no-heading --color=always --smart-case " . RgGlobQuery(<q-args>) . " || :", 1, fzf#vim#with_preview('right:50%'), 1)

command! -bang -nargs=? Files call fzf#vim#files(<q-args>, fzf#vim#with_preview('right:50%'), <bang>0)

let g:fzf_layout = { 'down': '50%' }

let g:fzf_action = {
  \ 'ctrl-t': 'silent tab drop',
  \ 'enter': 'silent tab drop',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let g:fzf_colors =
      \{ 'fg':      ['fg', 'Normal'],
      \  'bg':      ['bg', 'Normal'],
      \  'hl':      ['fg', 'Comment'],
      \  'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \  'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \  'hl+':     ['fg', 'Statement'],
      \  'info':    ['fg', 'PreProc'],
      \  'border':  ['fg', 'Ignore'],
      \  'prompt':  ['fg', 'Conditional'],
      \  'pointer': ['fg', 'Exception'],
      \  'marker':  ['fg', 'Keyword'],
      \  'spinner': ['fg', 'Label'],
      \  'header':  ['fg', 'Comment']
      \}

""""""""""""
" Fugitive "
""""""""""""

command! -nargs=0 GstatusTab :Gedit :

command! -nargs=* GdiffTab :Git difftool -y <q-args>

augroup fugitiveImprovement
  au!
  " enter should open the file in a new tab, not a split
  autocmd BufEnter * if @% =~ ".git/index$" | nnoremap <silent><buffer><expr> <CR> getline('.') =~ '[A-Z] [^ ]\+$' ? ":silent tab drop " . substitute(getline('.'), '[A-Z] \([^ ]\+\)$', '\1', '') . "\<CR>" : "\<CR>" | endif
augroup END

"""""""
" CoC "
"""""""

let g:coc_node_path=expand("$HOME/.nodenv/versions/13.2.0/bin/node")

let g:coc_snippet_next = '<Tab>'
let g:coc_global_extensions = [
      \ 'coc-diagnostic',
      \ 'coc-eslint',
      \ 'coc-explorer',
      \ 'coc-git',
      \ 'coc-go',
      \ 'coc-json',
      \ 'coc-pairs',
      \ 'coc-prettier',
      \ 'coc-snippets',
      \ 'coc-solargraph',
      \ 'coc-tsserver',
      \ 'coc-yaml'
      \ ]

" use tab for trigger completion with characters ahead and navigate.
" use command ':verbose imap <Tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>CheckBackspace() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

au FileType sh,bash nnoremap <buffer> <C-s> :w<Bar>call CocAction('format')<CR>

"""""""""""
" Endwise "
"""""""""""

let g:endwise_no_mappings = 1
inoremap <expr> <CR> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
imap <expr> <CR> complete_info()["selected"] != "-1" ? "\<C-Y>\<Plug>DiscretionaryEnd" : "\<CR>\<Plug>DiscretionaryEnd"

""""""""""""
" Prettier "
""""""""""""

command! -nargs=0 Prettier :CocCommand prettier.formatFile
au FileType javascript,jsx,typescript,json,typescriptreact nnoremap <buffer> <C-s> :w<Bar>Prettier<CR>

""""""""""""""""""""""""""
" FAR (Find and Replace) "
""""""""""""""""""""""""""

let g:far#source='rgnvim'
let g:far#default_file_mask='**/*'

"""""""""""""""
" JsAlternate "
"""""""""""""""

let g:js_alternate#extension_types = ['js', 'jsx', 'ts', 'tsx']

""""""""""""
" vim-iced "
""""""""""""

let g:iced_enable_default_key_mappings=v:true

""""""""""""""""
" vim-closetag "
""""""""""""""""

let g:closetag_filenames="*.html,*.xhtml,*.phtml,*.js"

""""""""""
" vim-go "
""""""""""

let g:go_fmt_command = "gofumports"
let g:go_def_mapping_enabled = 0

"""""""""""""""""
" vim-fireplace "
"""""""""""""""""

au FileType clojure nnoremap <buffer> <C-s> :w<Bar>silent Require<CR>
au FileType clojure nnoremap <buffer> <C-e> :Eval<CR>
au FileType clojure vnoremap <buffer> <C-e> :Eval<CR>

"""""""""""""""
" wordmotion "
"""""""""""""""

let g:wordmotion_prefix = '<Leader>'



"""""""""""""""
"""""""""""""""
"" FUNCTIONS ""
"""""""""""""""
"""""""""""""""

" duplicate current file into new tab
function! DuplicateFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':w ' . new_name
    exec ':tabe ' . new_name
    redraw!
  endif
endfunction

" quickly switch between a source and test file. Create the file
" if it doesn't exist. Works for Rails and JS tests.
function! SwitchBetweenSourceAndTest()
  let currentFile = expand('%')
  if currentFile =~ '\.rb$'
    if currentFile =~ '_spec\.rb$'
      if currentFile !~ '^spec\/requests'
        call OpenInNewTab(substitute(currentFile, 'spec\/\(.*\)_spec\.rb$', 'app/\1.rb', ''))
      endif
    else
      call OpenInNewTab(substitute(currentFile, 'app\/\(.*\)\.rb$', 'spec/\1_spec.rb', ''))
    endif
  elseif currentFile =~ '\.js$'
    if currentFile =~ '\.test\.js$'
      call OpenInNewTab(substitute(currentFile, '\(.*\)\/__tests__\/\(.*\)\.test\.js$', '\1/\2.js', ''))
    else
      call OpenInNewTab(substitute(currentFile, '\(.*\)\/\(.*\)\.js$', '\1/__tests__/\2.test.js', ''))
    endif
  endif
endfunction

function! OpenInNewTab(fileName)
  let filePath = substitute(a:fileName, '\(.*\)\/.*', '\1', '')
  if !filereadable(a:fileName)
    silent execute '!mkdir -p ' . '"' . filePath . '"'
  endif
  execute ':silent tab drop ' . a:fileName
endfunction

" reopen last tab
let g:reopenBufs = [expand('%:p')]
function! ReopenLastTabLeave()
  let g:lastBuf = expand('%:p')
  let g:lastTabCount = tabpagenr('$')
endfunction
function! ReopenLastTabEnter()
  if tabpagenr('$') < g:lastTabCount && g:lastBuf !~ '\/bin\/zsh' && g:lastBuf !~ 'fugitive:\/\/' && g:lastBuf !~ 'term:\/\/'
    let g:reopenBufs = g:reopenBufs + [g:lastBuf]
  endif
endfunction
function! ReopenLastTab()
  if len(g:reopenBufs) > 0
    let tabToOpen = g:reopenBufs[len(g:reopenBufs) - 1]
    if len(g:reopenBufs) > 1
      let g:reopenBufs = g:reopenBufs[0:-2]
    endif
    if tabToOpen != ''
      execute 'silent tab drop ' . tabToOpen
    endif
  endif
endfunction
augroup ReopenLastTab
  autocmd!
  autocmd TabLeave * call ReopenLastTabLeave()
  autocmd TabEnter * call ReopenLastTabEnter()
augroup END

" get word under cursor
function! GetWordUnderCursor()
  set iskeyword+=/,-
  let word = expand("<cword>")
  set iskeyword-=/,-
  return word
endfunction

function! CloseTab()
  try
    let file = expand('%:p')
    if file =~ '^list://'
      " no-op to force Esc usage
    elseif file =~ '\[List Preview\] ' || file =~ 'nvim.*/doc/.*\.txt$' || file =~ '\[coc-explorer\]'
      execute ":q"
    elseif tabpagenr('$') > 1
      execute ":tabclose"
    else
      execute ":windo q"
    end
  catch /./
    echo v:exception
  endtry
endfunction

" help with tab completion
function! s:CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" show the CoC documentation window
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h ' . expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" copy link to Gitiles
function! CopyGitilesLink()
  let project = system('basename `git rev-parse --show-toplevel` | tr -d "\n"')
  let current_file = expand("%")
  let @+ = 'https://gerrit.instructure.com/plugins/gitiles/' . project . '/+/master/' . current_file . '#' . line('.')
endfunction

" open the JS alternative file in a new tab
function! JsAlternateRun()
  let path = expand("%:r")
  let alternatives = js_alternate#alternatives(path)
  for alternative in alternatives
    if filereadable(alternative)
      exec ':tab drop ' . alternative
      break
    end
  endfor
endfunction

" create a ripgrep query including a glob for file
function! RgGlobQuery(globAndQuery)
  let splitUp = split(a:globAndQuery)
  let globExpression = splitUp[0]
  let query = join(splitUp[1:], ' ')
  return "--glob='" . globExpression . "' " . shellescape(query)
endfunction

" make the tabline more similar to airline
function! ImprovedTabline()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#' . ImprovedCurrentTabColor(i + 1) . '#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by ImprovedTabLabel()
    let s .= ' %{ImprovedTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  return s
endfunction

function! ImprovedCurrentTabColor(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  if getbufinfo(buflist[winnr - 1])[0].changed
    return 'TabLineChanged'
  else
    return 'TabLineSel'
  endif
endfunction

" make the tab names more similar to airline
function! ImprovedTabLabel(n)
  let explorer = 0
  let currentName = ''
  let currentDir = ''
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let windowsInTab = len(buflist)
  for bufnum in buflist
    let name = bufname(bufnum)
    if name =~ '\[coc-explorer\]'
      let explorer = 1
    elseif currentName == ''
      let currentName = bufname(bufnum)
      let currentDir = fnamemodify(currentName, ':h')
      if getbufinfo(bufnum)[0].changed
        let modified = '+ '
      else
        let modified = ''
      endif
    endif
  endfor
  if explorer == 1
    let explorer = '[EXPLORER] '
  else
    let explorer = ''
  endif
  if currentName == ''
    return explorer . modified . '[No Name]'
  elseif currentName =~ 'term://.*/bin/fzf'
    return explorer . modified . 'fzf'
  elseif currentName =~ '\.git/index$'
    return explorer . modified . 'git:status'
  elseif currentName =~ '^fugitive://.*'
    return explorer . modified . substitute(currentName, 'fugitive://.*/', 'git:', '')
  else
    let currentFile = fnamemodify(currentName, ':t')
    if currentDir == '.'
      return explorer . modified . currentFile
    endif
    let matches = []
    for tabnr in range(1, tabpagenr('$'))
      let buflist = tabpagebuflist(tabnr)
      let winnr = tabpagewinnr(tabnr)
      let name = bufname(buflist[winnr - 1])
      let file = fnamemodify(name, ':t')
      if name != currentName && file == currentFile
        call add(matches, name)
      endif
    endfor
    if len(matches) > 0
      let highest = [-1, '']
      for match in matches
        let currentDirs = split(fnamemodify(currentName, ':h'), '/')
        let matchDirs = split(fnamemodify(match, ':h'), '/')
        let level = 0
        while len(currentDirs) > level && len(matchDirs) > level
          if currentDirs[-1 - level] != matchDirs[-1 - level] && level > highest[0]
            if level > 0
              let highest = [level, currentDirs[-1 - level] . '/.../' . currentFile]
            else
              let highest = [0, currentDirs[-1] . '/' . currentFile]
            endif
          endif
          let level += 1
        endwhile
      endfor
      return explorer . modified . highest[1]
    else
      return explorer . modified . currentFile
    endif
  endif
endfunction

" play around with replace in project
" :cdo! s/back/yo/ce | silent update
