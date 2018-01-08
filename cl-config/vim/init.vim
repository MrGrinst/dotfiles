"""""""""""""""""""""""""
"""""""""""""""""""""""""
"" PLUGIN INSTALLATION ""
"""""""""""""""""""""""""
"""""""""""""""""""""""""

filetype off
call plug#begin()
Plug 'tpope/vim-surround'                                         " Easily surround objects with things like {, [, (, etc
Plug 'tpope/vim-fugitive'                                         " Great git integration
Plug 'tpope/vim-commentary'                                       " Nice commenting using commands
Plug 'tpope/vim-sleuth'                                           " Matches indentation style to the current file
Plug 'tpope/vim-repeat'                                           " Allows the . operator to be used for other plugins
Plug 'sheerun/vim-polyglot'                                       " Better support for many programming languages
Plug 'editorconfig/editorconfig-vim'                              " Allows use of .editorconfig file
Plug 'MrGrinst/vim-airline'                                       " Really nice status and tab bars
Plug 'vim-airline/vim-airline-themes'                             " Add support for themes
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }     " Auto-completion
Plug 'godlygeek/tabular'                                          " Allows aligning things nicely
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Fuzzy finder for opening files and some completions
Plug 'MrGrinst/fzf.vim'                                           " Set defaults for the fuzzy finder
Plug 'airblade/vim-gitgutter'                                     " Adds git info to the gutter
Plug 'pangloss/vim-javascript'                                    " Better JS syntax highlighting
Plug 'mxw/vim-jsx'                                                " JSX support
Plug 'Raimondi/delimitMate'                                       " Auto-close parens, brackets, quotes, etc
Plug 'alvan/vim-closetag'                                         " Better XML editing, mainly adding the ability to auto-close tags
Plug 'tpope/vim-endwise'                                          " Gives better support for Ruby blocks
Plug 'tmux-plugins/vim-tmux-focus-events'                         " Gives support for knowing when focus is gained and lost (allows file reloading)
Plug 'benmills/vimux'                                             " Allows running commands in tmux easily
Plug 'vim-syntastic/syntastic'                                    " Syntax checking like eslint
Plug 'vim-scripts/ReplaceWithRegister'                            " Make pasting over text nicer
Plug 'chaoren/vim-wordmotion'                                     " Make motion better
Plug 'morhetz/gruvbox'                                            " Awesome theme
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }                  " Clojure REPL
Plug 'guns/vim-clojure-static', { 'for': 'clojure' }              " Make Clojure development great again
Plug 'kien/rainbow_parentheses.vim'                               " Colors!
Plug 'clojure-vim/async-clj-omni', { 'for': 'clojure' }           " Clojure stuff
Plug 'SirVer/ultisnips'                                           " Save time with snippets!
Plug 'kana/vim-textobj-user'                                      " Add support for custom text objects
Plug 'kana/vim-textobj-entire'                                    " Add the entire file text object
call plug#end()
filetype plugin indent on



""""""""""""""""""""""
""""""""""""""""""""""
"" GENERAL SETTINGS ""
""""""""""""""""""""""
""""""""""""""""""""""

" Track undo history even after closing vim. Note: the directory must already be
" created
set undofile
set undodir=~/.vim_undo_files

set noswapfile

" Strip trailing whitespace on save
let strip_whitespace_blacklist = ['sql']
autocmd BufWritePre * if index(strip_whitespace_blacklist, &ft) < 0 | %s/\s\+$//e | endif

if has('mouse')
  set mouse=a
endif

" Ensure the autocomplete menu closes when I'm done with it
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
autocmd FocusLost * set nolazyredraw
autocmd FocusGained * set lazyredraw

let g:wordmotion_prefix = '<Leader>'

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

au FileType * setlocal textwidth=0
" Delete comment character when joining commented lines
au FileType * setlocal formatoptions+=j
" Add comment to next line when hitting Enter on comment line
au FileType * setlocal formatoptions+=r
" Prevent auto-commenting lines when using 'o' or 'O' on a comment line
au FileType * setlocal formatoptions-=o
" Prevent auto-wrapping of text
au FileType * setlocal formatoptions-=t
" Prevent auto-wrapping of lines with comments
au FileType * setlocal formatoptions-=c

if &history < 1000
  set history = 1000
endif
if &tabpagemax < 50
  set tabpagemax = 50
endif
if !empty(&viminfo)
  set viminfo^=!
endif



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

set completeopt+=longest
set completeopt+=menuone
set completeopt+=preview

" make vim use the clipboard for copying/pasting
set clipboard=unnamed



""""""""""""""""""""
""""""""""""""""""""
"" USER INTERFACE ""
""""""""""""""""""""
""""""""""""""""""""

" Don’t show the intro message when starting Vim
set shortmess=atI
" Searching
" case insensitive searching
set ignorecase
" case-sensitive if expression contains a capital letter
set smartcase
" Highlight search results
set hlsearch
" set incremental search, like modern browsers
set incsearch
" don't redraw while executing macros
set lazyredraw
" Use 'g' flag by default with :s/foo/bar/.
set gdefault
let loaded_matchparen = 1

" Say no to code folding...
set nofoldenable

" Set magic on, for regex
set magic
" No color column by default
set colorcolumn=

" how many tenths of a second to blink
set mat=2
" Show all text past column as an error
let highlight_long_lines_blacklist = ['fzf']
autocmd FileType * if index(highlight_long_lines_blacklist, &ft) < 0 | let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1) | endif
" Set a color column for commit messages
au FileType gitcommit setlocal colorcolumn=75

" toggle invisible characters
set list
set listchars=tab:→→,trail:⋅,extends:❯,precedes:❮
" make the highlighting of tabs and other non-text less annoying
highlight SpecialKey ctermbg=none ctermfg=8
highlight NonText ctermbg=none ctermfg=8

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

let &titlestring=@%
set title

" No beeps.
set noerrorbells visualbell t_vb=

set laststatus=2

" More natural splits
" Horizontal split below current.
set splitbelow
" Vertical split to right of current.
set splitright
set switchbuf+=usetab,newtab



""""""""""""""""""
""""""""""""""""""
"" THEME/COLORS ""
""""""""""""""""""
""""""""""""""""""

" WARNING: DO NOT CHANGE ORDER OR THEME WILL NOT WORK
" Switch syntax highlighting on
syntax on
" Set the encoding
set encoding=utf8
" Obviously need a dark background!
set background=dark
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark='soft'
let g:gruvbox_termcolors=16
" Set the color scheme to gruvbox. Silent means it won't fail the first time we start vim
silent! colorscheme gruvbox
" Use normal line number for the selected line
set number
set timeout
set timeoutlen=350
" Ensure there is no delay when escaping from insert mode
set ttimeout
" Ensure there is no delay when escaping from insert mode
set ttimeoutlen=1
highlight ErrorMsg ctermbg=None ctermfg=None cterm=underline
" make comments italic
highlight Comment cterm=italic



""""""""""""""
""""""""""""""
"" MAPPINGS ""
""""""""""""""
""""""""""""""

"""""""""""""""
" Normal Mode "
"""""""""""""""

" Make movement work regardless of line wrapping
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$

" Prevent <C-z> from suspending
nnoremap <C-z> <nop>

" Automatically indent after pasting
nnoremap <silent> p pmz`[v`]=`z
vnoremap <silent> p pmz`[v`]=`z

" Map <C-[> to go back in file stack (requires iTerm2 mapping)
nnoremap <M-=> <C-o>

" Emulate something similar to ctags by searching for files with
" the name of what's under the cursor
nnoremap <silent> <expr> <C-]> ":Files\<CR>" . GetWordUnderCursor()

" Map U to redo
nnoremap U <C-r>

" Use Q to execute default macro
nnoremap <silent> Q @q

tnoremap <silent> <Left> <C-\><C-n>:tabp<CR>
tnoremap <silent> <Right> <C-\><C-n>:tabn<CR>
nnoremap <silent> <Left> :tabp<CR>
nnoremap <silent> <Right> :tabn<CR>
nnoremap <silent> <M-b> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <M-f> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

nnoremap * /\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap # ?\<<C-R>=expand('<cword>')<CR>\><CR>

nnoremap n nzz
nnoremap N Nzz

nnoremap <expr> A getline(line(".")) =~ "^$" ? "cc" : "A"

nnoremap yy y$

nmap yae yae<C-o>

vmap <C-_><C-_> y'>pgvgc'>j
nmap <C-_><C-_> Ypkgccj

nnoremap <silent> <Esc> :call CancelReplaceInFile() <bar> :noh<CR>
inoremap <silent> <Esc> <Esc>:call ContinueReplaceInFile() <bar> :noh<CR>
vnoremap <silent> <Esc> <Esc>:noh<CR>

nnoremap <C-s> :w<CR>
au FileType clojure nnoremap <buffer> <C-s> :w<bar>silent Require<CR>
au FileType clojure nnoremap <buffer> <C-e> :Eval<CR>
au FileType clojure vnoremap <buffer> <C-e> :Eval<CR>

nnoremap <silent> & :call BeginReplaceInFile()<CR>
nnoremap , @@

nnoremap <C-t> :Files!<CR>
nnoremap <C-f> :Ag<Space>
" Stops the command history window from popping up
map q: <nop>

" Use ; for commands.
nnoremap ; :
vnoremap ; :
" So I actually learn the ; mapping
nnoremap : <nop>
vnoremap : <nop>

" Stop space from doing anything
nnoremap <Space> <nop>

" better scrolling
nnoremap <Down> <C-d>
nnoremap <Up>   <C-u>
vnoremap <Down> <C-d>
vnoremap <Up>   <C-u>

nnoremap <silent> <C-r> :w <bar> call VimuxOpenRunner() <bar> call VimuxSendKeys("C-c Up Enter")<CR>

" Ctrl-N to open a new file like most modern editors
nnoremap <C-n> :tabe<CR>

" Ctrl-X to close a tab like most modern editors
nnoremap <C-x> :call CloseTab()<CR>

" Closed tab history. Reopen with Cmd-Shift-T
nnoremap <silent> <M-t> :call ReopenLastTab()<CR>

vmap <C-_> gc
nmap <C-_> gcc

nnoremap <tab> >>
nnoremap <M-`> <<
vnoremap <tab> >
vnoremap <M-`> <


"""""""""""""""
" Insert Mode "
"""""""""""""""

" consistent menu navigation
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
" Deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"
inoremap <expr><M-`> pumvisible() ? "\<C-p>" : "\<tab>"

" Enable alt-backspace
imap <A-BS> <C-W>

" Enable command-backspace (requires iTerm2 mapping)
imap <A-?> <C-u>



"""""""""""""""""""""
"""""""""""""""""""""
"" LEADER MAPPINGS ""
"""""""""""""""""""""
"""""""""""""""""""""

" Set leader key to <Space>
let mapleader=' '

" Copy path of current file
nnoremap <silent><Leader>c :let @+ = expand("%")<CR>

" Rename the current file
nnoremap <Leader>n :call RenameFile()<CR>

" Duplicate the current file into another tab
nnoremap <Leader>d :call DuplicateFile()<CR>

" Search and replace
nnoremap <Leader>s :%s//<Left>

" Switch between a source file and test file (Rails/React)
nnoremap <silent><Leader>p :call SwitchBetweenSourceAndTest()<CR>

" Navigate quickfix
nnoremap <Leader>] :cnext<CR>
nnoremap <Leader>[ :cprev<CR>



"""""""""""""""""""""
"""""""""""""""""""""
"" PLUGIN SETTINGS ""
"""""""""""""""""""""
"""""""""""""""""""""

let g:delimitMate_expand_cr=1
let g:closetag_filenames="*.html,*.xhtml,*.phtml,*.js"
let g:polyglot_disabled=['jsx']
let g:deoplete#enable_at_startup=1


"""""""
" Fzf "
"""""""

" Hide statusline of terminal buffer
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
                   \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
                   \| autocmd BufEnter <buffer> set laststatus=0 noshowmode noruler | startinsert

command! -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview('right:50%'), 1)

command! -bang -nargs=? Files call fzf#vim#files(<q-args>, fzf#vim#with_preview('right:50%'), <bang>0)

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
autocmd BufReadPost fugitive://* set bufhidden=delete

" Open a new tab with Git status
nnoremap <silent><Leader>- :Gcd .<CR>:tabedit %<CR>:Gstatus<CR><C-w><Up>:q<CR>

augroup fugitiveStatusImprovement
  au!
  " Easily move between file diffs in status mode.
  autocmd BufEnter * if @% =~ "^fugitive:\/\/" && winnr('$') == 3 | nmap <silent> <Leader>] <C-w><Up><C-n>D | nmap <silent> <Leader>[ <C-w><Up><C-p>D | endif
  " Enter should open the file in a new tab, not a split
  autocmd BufEnter * if @% == ".git/index" | nnoremap <silent><buffer><expr> <CR> getline('.') =~ '.*\(:\\|->\)\s*.\+$' ? ":silent tab drop " . substitute(getline('.'), '.*\(:\\|->\)\s*\(.\+\)$', '\2', '') . "\<CR>" : "\<CR>" | endif
augroup END

"""""""""""""
" GitGutter "
"""""""""""""
set signcolumn=yes
let g:gitgutter_diff_args='HEAD'

""""""""""""
" Vim-node "
""""""""""""
autocmd User Node
  \ if &filetype == "javascript" |
  \   nmap <buffer> <C-w>f <Plug>NodeVSplitGotoFile |
  \   nmap <buffer> <C-w><C-f> <Plug>NodeVSplitGotoFile |
  \ endif

""""""""""""""""""""""""""""""""""""
" Airline (top and bottom UI bars) "
""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts=1                                  " Use the powerline fonts (looks super nice)
let g:airline_section_y=''                                       " Don't show file encoding or operating system
let g:airline_section_z='%#__accent_bold#%L%#__restore__# :%2v'  " Only show useful info at bottom right
let g:webdevicons_enable_airline_statusline_fileformat_symbols=0 " Don't show file encoding or operating system
let g:airline#extensions#tabline#enabled=1                       " Enable tabline at the top
let g:airline#extensions#tabline#show_buffers=0                  " Show tabs instead of buffers
let g:airline#extensions#tabline#show_splits=0                   " Don't show splits
let g:airline#extensions#tabline#show_tab_nr = 0                 " Don't show tab numbers
let g:airline#extensions#tabline#show_tab_type = 0               " Don't show type: tab/buffer
let g:airline#extensions#tabline#formatter = 'unique_tail_super_improved' " Show the unique part of the filename
let g:airline#extensions#tabline#show_close_button = 0           " Don't show the close button

"""""""""""""
" Syntastic "
"""""""""""""
let g:syntastic_javascript_checkers=['eslint']
let g:syntastic_javascript_eslint_exe='$(npm bin)/eslint'

"""""""""""
" Vim-JSX "
"""""""""""
let g:jsx_ext_required = 0

"""""""""""""
" UltiSnips "
"""""""""""""
set rtp+=~/Developer/dotfiles/cl-config/vim
let g:UltiSnipsSnippetsDir="~/Developer/dotfiles/cl-config/vim/UltiSnips"
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"



"""""""""""""""
"""""""""""""""
"" FUNCTIONS ""
"""""""""""""""
"""""""""""""""

" Rename current file (thanks Gary Bernhardt and Ben Orenstein)
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction

" Duplicate current file into new tab
function! DuplicateFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':w ' . new_name
    exec ':tabe ' . new_name
    redraw!
  endif
endfunction

" Quickly switch between a source and test file. Create the file
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

" Reopen last tab
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
  tabnew
  let tabToOpen = g:reopenBufs[len(g:reopenBufs) - 1]
  if len(g:reopenBufs) > 1
    let g:reopenBufs = g:reopenBufs[0:-2]
  endif
  execute 'buffer' . tabToOpen
endfunction
augroup ReopenLastTab
  autocmd!
  autocmd TabLeave * call ReopenLastTabLeave()
  autocmd TabEnter * call ReopenLastTabEnter()
augroup END

" Get word under cursor
function! GetWordUnderCursor()
  set iskeyword+=/,-
  let word = tolower(substitute(expand("<cword>"), "_", "", ""))
  set iskeyword-=/,-
  return word
endfunction

function! CloseTab()
  if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    :q
  else
    :bd
  endif
endfunction

function! BeginReplaceInFile()
  let g:replacingInFile = 1
  let word = expand("<cword>")
  let @/ = word."\\C"
  normal qa
endfunction

function! ContinueReplaceInFile()
  if get(g:, 'replacingInFile', 0)
    normal qn
    let @b = ""
    normal @b
    let @b = @a . "n"
    let g:replacingInFile = 0
  endif
endfunction

function! CancelReplaceInFile()
  let g:replacingInFile = 0
endfunction

" Play around with replace in project
" :cdo! s/back/yo/ce | silent update
