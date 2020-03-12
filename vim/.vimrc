let mapleader=","
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>


set nowrap        " don't wrap lines
set tabstop=4     " a tab is four spaces
set backspace=indent,eol,start
                    " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting
set number        " always show line numbers
set shiftwidth=4  " number of spaces to use for autoindenting
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                    "    case-sensitive otherwise
set smarttab      " insert tabs on the start of a line according to
                    "    shiftwidth, not tabstop
set hlsearch      " highlight search terms
set incsearch     " show search matches as you type

set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep

set nobackup
set noswapfile


" sudo trick w!! - save
cmap w!! w !sudo tee % >/dev/null

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

nmap <leader>ne :NERDTree<cr>
" git
nmap <silent> <leader>ge :GitGutterEnable<cr>
nmap <silent> <leader>gg :GitGutterToggle<cr>
" git 
nmap <space>gb :Gblame<cr>
nmap <space>gs :Gstatus<cr>
nmap <space>gc :Gcommit -v<cr>
nmap <space>ga :Git add -p<cr>
nmap <space>gm :Gcommit --amend<cr>
nmap <space>gp :Gpush<cr>
nmap <space>gd :Gdiff<cr>
nmap <space>gw :Gwrite<cr>

set pastetoggle=<F2>

call plug#begin('~/.vim/plugged')
Plug 'OmniSharp/omnisharp-vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Use release branch (Recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'sodapopcan/vim-twiggy'
Plug 'airblade/vim-gitgutter', {'on': 'GitGutterEnable'}
Plug 'tomasr/molokai'
Plug 'morhetz/gruvbox'
Plug 'lifepillar/vim-solarized8'
call plug#end()

" colorsceme and true colors
colorscheme gruvbox
let g:lightline = { 'colorscheme': 'challenger_deep'}
" True Colour
if has('nvim') || has('termguicolors')
  set termguicolors
endif

