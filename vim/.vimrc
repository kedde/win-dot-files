let mapleader=","
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>ev :tabedit $MYVIMRC<CR>
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

" -----------------------------------------
" | Plugins using vim-plug
" -----------------------------------------
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
Plug 'dense-analysis/ale'
Plug 'ctrlpvim/ctrlp.vim'
call plug#end()

" If the current buffer has never been saved, it will have no name,
" " call the file browser to save it, otherwise just save it.
nnoremap <silent> <C-S> :if expand("%") == ""<CR>browse confirm w<CR>else<CR>confirm w<CR>endif<CR>
" copy paste
map <C-a> ggVG
map <C-c> "+y
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
nmap <leader>gb :Gblame<cr>
nmap <leader>gs :Gstatus<cr>
nmap <leader>gc :Gcommit -v<cr>
nmap <leader>ga :Git add -p<cr>
nmap <leader>gm :Gcommit --amend<cr>
nmap <leader>gp :Gpush<cr>
nmap <leader>gd :Gdiff<cr>
nmap <leader>gw :Gwrite<cr>

" nerdtree - map keys as the intellij bindings in VS
nmap <A-L> :NERDTreeFind<cr>
" issue with ctrl+alt in windows terminal?
nmap <C-A-l> :NERDTreeFocus<cr>
nmap <F6> :NERDTreeToggle<cr>
nmap <C-A-d> :NERDTreeToggle<cr>

" COC
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" -----------------------------
" ctrl p
" -----------------------------
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|node_modules|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" -----------------------------
" OmniSharp
" -----------------------------
" filetype indent plugin on
let g:OmniSharp_server_stdio = 1
let g:OmniSharp_highlight_types = 3
let g:ale_linters = { 'cs': ['OmniSharp'] }
set completeopt=longest,menuone,preview

augroup omnisharp_commands
    autocmd!

    " Show type information automatically when the cursor stops moving.
    " Note that the type is echoed to the Vim command line, and will overwrite
    " any other messages in this space including e.g. ALE linting messages.
    autocmd CursorHold *.cs OmniSharpTypeLookup

    " The following commands are contextual, based on the cursor position.
    autocmd FileType cs nnoremap <buffer> gd :OmniSharpGotoDefinition<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fi :OmniSharpFindImplementations<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fs :OmniSharpFindSymbol<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>fu :OmniSharpFindUsages<CR>

    " Finds members in the current buffer
    autocmd FileType cs nnoremap <buffer> <Leader>fm :OmniSharpFindMembers<CR>

    autocmd FileType cs nnoremap <buffer> <Leader>fx :OmniSharpFixUsings<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>tt :OmniSharpTypeLookup<CR>
    autocmd FileType cs nnoremap <buffer> <Leader>dc :OmniSharpDocumentation<CR>
    autocmd FileType cs nnoremap <buffer> <C-\> :OmniSharpSignatureHelp<CR>
    autocmd FileType cs inoremap <buffer> <C-\> <C-o>:OmniSharpSignatureHelp<CR>

    " Navigate up and down by method/property/field
    autocmd FileType cs nnoremap <buffer> <A-k> :OmniSharpNavigateUp<CR>
    autocmd FileType cs nnoremap <buffer> <A-j> :OmniSharpNavigateDown<CR>

    " Find all code errors/warnings for the current solution and populate the quickfix window
    autocmd FileType cs nnoremap <buffer> <Leader>cc :OmniSharpGlobalCodeCheck<CR>
augroup END


" Contextual code actions (uses fzf, CtrlP or unite.vim when available)
nnoremap <Leader><Space> :OmniSharpGetCodeActions<CR>
" Run code actions with text selected in visual mode to extract method
xnoremap <Leader><Space> :call OmniSharp#GetCodeActions('visual')<CR>

" Rename with dialog
nnoremap <Leader>nm :OmniSharpRename<CR>
nnoremap <F2> :OmniSharpRename<CR>
nnoremap <leader>ct :OmniSharpRunTest<CR>
nnoremap <leader>rt :OmniSharpRunTestsInFile<CR>
" Rename without dialog - with cursor on the symbol to rename: `:Rename newname`
command! -nargs=1 Rename :call OmniSharp#RenameTo("<args>")

nnoremap <Leader>cf :OmniSharpCodeFormat<CR>

" Start the omnisharp server for the current solution
nnoremap <Leader>ss :OmniSharpStartServer<CR>
nnoremap <Leader>sp :OmniSharpStopServer<CR>

" Update semantic highlighting after all text changes

set pastetoggle=<leader><F2>

" colorsceme and true colors
colorscheme gruvbox
let g:lightline = { 'colorscheme': 'challenger_deep'}
" True Colour
if has('nvim') || has('termguicolors')
  set termguicolors
endif

