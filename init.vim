" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
"call plug#begin('~/.vim/plugged')
call plug#begin('~/.local/share/nvim/plugged')

"" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Vim colorschemes
Plug 'flazz/vim-colorschemes'

" Vim ctrlspace
Plug 'vim-ctrlspace/vim-ctrlspace'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Using a non-master branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}


" Plugin options

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

Plug 'vim-airline/vim-airline'            " Lean & mean status/tabline for vim
Plug 'vim-airline/vim-airline-themes'     " Themes for airline
"Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'                  " Tagbar
Plug 'neomake/neomake'                    " Asynchronous Linting and Make Framework
"Plug 'jreybert/vimagit'

Plug 'kien/rainbow_parentheses.vim'       " Rainbow Parentheses
"Plug 'ryanoasis/vim-devicons'             " Dev Icons

""-------------------=== Languages support ===-------------------
Plug 'scrooloose/nerdcommenter'           " Easy code documentation
Plug 'mitsuhiko/vim-sparkup'              " Sparkup(XML/jinja/htlm-django/etc.) support
Plug 'w0rp/ale'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

" Initialize plugin system
call plug#end()

" Clang completion for deoplete:
" Change clang binary path
"autocmd BufRead,BufNewFile *.c call deoplete#enable()
"call deoplete#custom#var('clangx', 'clang_binary', '/usr/bin/clang')
" Change clang options
"call deoplete#custom#var('clangx', 'default_c_options', '')
"call deoplete#custom#var('clangx', 'default_cpp_options', '')

" Enabling for certain file extensions
"autocmd FileType txt
"\ call deoplete#custom#buffer_option('auto_complete', v:true)
"
"autocmd FileType c
"\ call deoplete#custom#buffer_option('auto_complete', v:true)

"autocmd FileType py
"\ call deoplete#custom#buffer_option('auto_complete', v:true)

" NT settings
" Start nerdtree if no file in edit or opening a directory, and close if it's the only thing open
"autocmd StdinReadPre * let s:std_in=1
"autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
"autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" NT toggle
nmap " :NERDTreeToggle<CR>

" Begin Themes:
colo seoul256
set background=dark

" Neomake
call neomake#configure#automake('w')
let g:neomake_open_list = 2


" History
set incsearch	                            " incremental search
set hlsearch	                            " highlight search results

" Relative Numbering
nnoremap <F4> :set relativenumber!<CR>

" Airline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail'
let g:airline_powerline_fonts=1
"let g:airline_theme='deus'
let g:airline_theme='zenburn'

colorscheme zenburn
" Tagbar toggle
nmap <F8> :TagbarToggle<CR>

" General settings
set number
set encoding=utf8
let base16colorspace=256
set ttyfast
set showmatch
set clipboard=unnamed
set exrc
set secure
set t_Co=256
set hidden
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set autoindent

syntax enable
tab sball
set switchbuf=useopen
set laststatus=2
nmap <F9> :bprev<CR>
nmap <F10> :bnext<CR>
nmap <silent> <leader>q :SyntasticCheck # <CR> :bp <BAR> bd #<CR>
set backspace=indent,eol,start

"let g:pymode_python = 'python3'
"set pyxversion=3
let $NVIM_PYTHON_LOG_FILE="/tmp/nvim_log"
let $NVIM_PYTHON_LOG_LEVEL="DEBUG"

set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

"=====================================================
"" NERDComment Settings 
"=====================================================
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Use compact syntax for prettified multi-line comments
let g:NERDCompactSexyComs = 1

" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'

" Set a language to use its alternate delimiters by default
let g:NERDAltDelims_java = 1

" Add your own custom formats or override the defaults
let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" Call neomake when writing a buffer (no delay).
call neomake#configure#automake('w')

" neovim QoL Configs:
" So we can actually leave insert mode in nvim
tnoremap <Esc> <C-\><C-n> 
" Coloring the terminal cursor red
highlight TermCursor ctermfg=red guifg=red





