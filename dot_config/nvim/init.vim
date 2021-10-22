set encoding=utf8           " encode in utf8
set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching brackets.
set ignorecase              " case insensitive matching
set mouse=nv                " middle-click paste with mouse
set hlsearch                " highlight search results
set tabstop=4               " number of columns occupied by a tab character
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set smartindent             " indent a new line the same amount as the line just typed
set relativenumber          " add relative line numbers
set wildmode=longest,list   " get bash-like tab completions
set viminfo^=%              " remember opened buffers
filetype plugin indent on   " allows auto-indenting depending on file type
syntax on                   " syntax highlighting

inoremap jk <esc>
nnoremap <SPACE> <Nop>
let mapleader=' '
nnoremap <silent> <leader>s :update<enter>
nnoremap <silent> <leader>q :q<enter>
" buffer
nnoremap <silent> <leader>x :bd<enter>
nnoremap <silent> <leader>b :Buffers<enter>
nnoremap <silent> <leader>n :bn<enter>
nnoremap <silent> <leader>p :bp<enter>

""" Language
" autocmd FileType go nnoremap <buffer> <leader>lb :GoBuild<enter>
" autocmd FileType go nnoremap <buffer> <leader>lr :GoRun .<enter>
" autocmd FileType go nnoremap <buffer> <leader>lt :GoTest<enter>

" Plugin
call plug#begin()
    Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'preservim/nerdtree'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'sheerun/vim-polyglot'
    Plug 'vim-airline/vim-airline'
    Plug 'sonph/onehalf', { 'rtp': 'vim' }
call plug#end()

""" theme
set t_Co=256
set cursorline
colorscheme onehalfdark
let g:airline_theme='onehalfdark'

""" Airline
" Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1

" Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'

""" OmniSharp
let g:OmniSharp_selector_ui = 'fzf'

""" Fzf
nnoremap <leader>f :Files<enter>

""" NerdTree
nnoremap <silent> <leader>a :NERDTreeToggle<enter>

""" Coc
""" See https://github.com/neoclide/coc.nvim
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting code.
"TODO nmap <leader>ff <Plug>(coc-format)

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
