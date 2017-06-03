"""""""""""""""""""""""
" PLUGIN INSTALLATION "
"""""""""""""""""""""""
filetype off
call plug#begin()
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeSteppedToggle' }     " Nice filetree sidebar
Plug 'tpope/vim-surround'                                         " Easily surround objects with things like {, [, (, etc
Plug 'tpope/vim-fugitive'                                         " Great git integration
Plug 'tpope/vim-commentary'                                       " Nice commenting using commands
Plug 'tpope/vim-sleuth'                                           " Matches indentation style to the current file
Plug 'tpope/vim-repeat'                                           " Allows the . operator to be used for other plugins
Plug 'vim-airline/vim-airline'                                    " Really nice information status bar at the bottom
Plug 'vim-airline/vim-airline-themes'                             " Adds themes for airline
Plug 'sheerun/vim-polyglot'                                       " A plugin to provide better support for various languages
Plug 'rakr/vim-one'                                               " Awesome theme based on Atom's theme
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }     " Auto-completion
Plug 'MrGrinst/vim-nerdtree-tabs'                                 " Makes using NERDTree with tabs better
Plug 'xolox/vim-misc'                                             " Dependency for vim-session
Plug 'xolox/vim-session'                                          " Nice way to manage editing sessions
Plug 'godlygeek/tabular'                                          " Allows aligning things nicely
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } " Fuzzy finder for opening files and some completions
Plug 'junegunn/fzf.vim'                                           " Set defaults for the fuzzy finder
Plug 'airblade/vim-gitgutter'                                     " Adds git info to the gutter
Plug 'Xuyuanp/nerdtree-git-plugin' " Shows git information in NERDTree
Plug 'vim-scripts/matchit.zip'
Plug 'gregsexton/MatchTag', { 'for': ['html', 'jsx'] }
Plug 'mxw/vim-jsx', { 'for': ['jsx', 'javascript'] } " JSX support
Plug 'alvan/vim-closetag'
Plug 'cohama/lexima.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'benmills/vimux'
Plug 'lervag/vimtex'
call plug#end()
filetype plugin indent on

let g:vimtex_compiler_method = 'latexrun'

nnoremap <silent> <C-r> :w \| call VimuxOpenRunner() \| call VimuxSendKeys("C-c Up Enter")<CR>

let g:gitgutter_sign_column_always = 1

" Enable deoplete
let g:deoplete#enable_at_startup = 1

" Track undo history even after closing vim. Note: the directory must already be
" created
set undofile
set undodir=~/.vim_undo_files

if has('mouse')
  set mouse=a
endif

" Ensure the autocomplete menu closes when I'm done with it
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

set ttyfast                    " faster redrawing
set nocompatible               " not compatible with vi
set autoread                   " detect when a file is changed
set backspace=indent,eol,start " make backspace behave in a sane manner
let mapleader = ' '            " Set leader key to <Space>

" Indentation and tabs
set expandtab
set smarttab                   " tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
set tabstop=4                  " the visible width of tabs
set softtabstop=4              " edit as if the tabs are 4 characters wide
set shiftwidth=4               " number of spaces to use for indent and unindent
set shiftround                 " round indent to a multiple of 'shiftwidth'
set autoindent " automatically set indent of new line
set smartindent

set completeopt+=longest
set completeopt+=menuone

set clipboard=unnamed          " make vim use the clipboard for copying/pasting

set complete-=i

""""""""""""""""""
" USER INTERFACE "
""""""""""""""""""
set shortmess=atI " Don’t show the intro message when starting Vim
" Searching
set ignorecase " case insensitive searching
set smartcase " case-sensitive if expression contains a capital letter
set hlsearch " Highlight search results
set incsearch " set incremental search, like modern browsers
set lazyredraw " don't redraw while executing macros
set gdefault  " Use 'g' flag by default with :s/foo/bar/.

set nofoldenable " Say no to code folding...

set magic " Set magic on, for regex

set mat=2 " how many tenths of a second to blink
" Show all text past column 120 in red
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)

" toggle invisible characters
set list
set listchars=tab:→→,trail:⋅,extends:❯,precedes:❮
" make the highlighting of tabs and other non-text less annoying
highlight SpecialKey ctermbg=none ctermfg=8
highlight NonText ctermbg=none ctermfg=8

" highlight conflicts
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" THEME/COLORS (WARNING: DO NOT CHANGE ORDER OR SCHEME WILL NOT WORK) "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                         " Switch syntax highlighting on
let $NVIM_TUI_ENABLE_TRUE_COLOR=1 " Let nvim do its thing with full colors
set termguicolors                 " Use awesome colors
set encoding=utf8                 " Set the encoding
set background=dark               " Obviously need a dark background!
let g:one_allow_italics = 1       " This allows the color scheme to use italics
silent! colorscheme one           " Set the color scheme to one. Silent means it won't fail the first time we start vim
set relativenumber                " Use relative numbering for all lines
set number                        " Use normal line number for the selected line
set ttimeout                      " Ensure there is no delay when escaping from insert mode
set ttimeoutlen=1                 " Ensure there is no delay when escaping from insert mode


" make comments and HTML attributes italic
highlight Comment cterm=italic
highlight htmlArg cterm=italic

let &titlestring=@%
set title

set noerrorbells visualbell t_vb=        " No beeps.

set laststatus=2

" More natural splits
set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current.

""""""""""""""""""""""""
" NORMAL MODE MAPPINGS "
""""""""""""""""""""""""
" Make movement work regardless of line wrapping
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> ^ g^
nnoremap <silent> $ g$

" Helpers for dealing with other people's code
nnoremap \t :set ts=4 sts=4 sw=4 noet<CR>
nnoremap \s :set ts=4 sts=4 sw=4 et<CR>

" Use Q to execute default register.
nnoremap Q @q

nnoremap <C-h> :tabp<CR>
nnoremap <C-l> :tabn<CR>
nnoremap <silent> <A-h> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-l> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

nnoremap * /\<<C-R>=expand('<cword>')<CR>\><CR>
nnoremap # ?\<<C-R>=expand('<cword>')<CR>\><CR>

nnoremap n nzz
nnoremap N Nzz

nnoremap <C-q> :SaveSession<CR>:CloseSession<CR>:q<CR>

nnoremap <silent> <ESC> :noh<CR>

nnoremap <C-s> :w<CR>
au FileType tex nnoremap <buffer> <C-s> :silent w <bar> :VimtexCompile<CR>

nnoremap <C-t> :Files!<CR>
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
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>

" Ctrl-N to open a new file like most modern editors
nnoremap <C-n> :tabe<CR>

" Ctrl-X to close a tab like most modern editors
nnoremap <C-x> :q<CR>

" Open previously closed tab
nnoremap <M-t> :tabnew<CR>:set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>

nmap yy Y

vmap <C-_> gc
nmap <C-_> gcc

""""""""""""""""""""""""
" INSERT MODE MAPPINGS "
""""""""""""""""""""""""
" consistent menu navigation
inoremap <C-j> <C-n>
inoremap <C-k> <C-p>
" Allow completing whole lines with fzf
imap <C-x><C-l> <plug>(fzf-complete-line)
" Deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<C-n>" : "\<tab>"

" Make Esc close the autocomplete menu
imap <expr><ESC> pumvisible() ? deoplete#mappings#close_popup() : "\<ESC>"

" Make Enter accept the highlighted autocomplete option
imap <expr><CR> pumvisible() ? "\<C-n>\<C-y>" : "\<CR>"


"""""""""""""""""""
" LEADER MAPPINGS "
"""""""""""""""""""

" Toggle NERDTree
nnoremap <silent> <leader>k :NERDTreeSteppedToggle<CR>
" expand to the path of the file in the current buffer
nnoremap <silent> <leader>y :NERDTreeTabsFind<CR>
" View commits in fzf
nnoremap <Leader>c :Commits<CR>
nnoremap <Leader>n :call RenameFile()<CR>
" Search and Replace
nnoremap <Leader>s :%s//<Left>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""
" NERDTREE "
""""""""""""
let NERDTreeShowHidden=1 " show hidden files in NERDTree
let NERDTreeIgnore = ['^\.DS_Store$']
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1

"""""""
" FZF "
"""""""
autocmd! VimEnter * command! Ag :call fzf#vim#ag_raw(empty(<q-args>) ? "'^(?=.)\'" : <q-args>,
\ {'options': "--preview 'coderay $(cut -d: -f1 <<< {}) 2> /dev/null | sed -n $(cut -d: -f2 <<< {}),\\$p | head -".&lines."'"}, 1)

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_layout = { 'down': '~30%' } " Set fzf layout
let g:fzf_buffers_jump = 1 " [Buffers] Jump to the existing window if possible
" File preview using coderay (http://coderay.rubychan.de/)
let g:fzf_files_options =
  \ '--preview "(coderay {} || cat {}) 2> /dev/null | head -'.&lines.'"'

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

""""""""""""
" SESSIONS "
""""""""""""
let g:session_autosave = 'no'       " Don't autosave sessions
let g:session_autoload = 'no'       " Don't autoload sessions
let g:session_autosave_periodic = 1 " Save the session periodically
let g:session_persist_colors = 0    " Make sure color scheme don't get screwed up by vim-session
let g:session_persist_font = 0      " Make sure the font isn't persisted either
set sessionoptions-=options         " Always reload config even with saved sessions
set sessionoptions-=buffers         " Remove closed buffers from saved sessions

""""""""""""""""""""""""""""""""""""
" AIRLINE (top and bottom UI bars) "
""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1                                  " Use the powerline fonts (looks super nice)
let g:airline_section_y=''                                         " Don't show file encoding or operating system
let g:webdevicons_enable_airline_statusline_fileformat_symbols = 0 " Don't show file encoding or operating system
let g:airline_theme='one'                                          " Use the OneDark theme
let g:airline#extensions#tabline#enabled = 1                       " Enable tabline at the top
let g:airline#extensions#tabline#show_buffers = 0                  " Show tabs instead of buffers
let g:airline#extensions#tabline#show_splits = 0                   " Don't show splits
let g:airline#extensions#tabline#fnamemod = ':t'                   " Only show the filename
let g:airline#extensions#tabline#fnamecollapse = 1                 " TODO

if !&scrolloff
  set scrolloff=3
endif
if !&sidescrolloff
  set sidescrolloff=5
endif
set display+=lastline

au FileType * setlocal textwidth=0
au FileType * setlocal formatoptions+=j " Delete comment character when joining commented lines
au FileType * setlocal formatoptions+=r " Add comment to next line when hitting Enter on comment line
au FileType * setlocal formatoptions-=o " Prevent auto-commenting lines when using 'o' or 'O' on a comment line
au FileType * setlocal formatoptions-=t " Prevent auto-wrapping of text
au FileType * setlocal formatoptions-=c " Prevent auto-wrapping of lines with comments

if has('path_extra')
  setglobal tags-=./tags tags-=./tags; tags^=./tags;
endif

if &history < 1000
  set history=1000
endif
if &tabpagemax < 50
  set tabpagemax=50
endif
if !empty(&viminfo)
  set viminfo^=!
endif

"""""""""""""
" FUNCTIONS "
"""""""""""""

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

" vp doesn't replace paste buffer
" note, I probably don't need this if I can get the replace word plugin working
" TODO: use this
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
