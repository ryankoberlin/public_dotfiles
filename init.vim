" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Vim colorschemes
Plug 'flazz/vim-colorschemes'

" Vim ctrlspace
Plug 'vim-ctrlspace/vim-ctrlspace'

" Vim devicons
Plug 'ryanoasis/vim-devicons'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Asynchronous Linting and Make Framework
Plug 'neomake/neomake'

" Rainbow Parentheses
Plug 'kien/rainbow_parentheses.vim'

" Tagbar
Plug 'majutsushi/tagbar'

" Asynchronous Linting Engine
Plug 'w0rp/ale'

" Autoformat
Plug 'Chiel92/vim-autoformat'

" Vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" Vimwiki
Plug 'vimwiki/vimwiki'

" Vim Surround
Plug 'tpope/vim-surround'

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

" Neomake
call neomake#configure#automake('w')
let g:neomake_open_list = 2



" General settings
set number                                  " Line numbers
set encoding=utf8
let base16colorspace=256
set ttyfast
set showmatch                               " Show matching 
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
set foldcolumn=1
set incsearch	                            " incremental search
set hlsearch	                            " highlight search results
set cursorline                              " Highlight line

au Filetype perl setlocal ts=3 sw=3 expandtab
au FileType perl set autoindent|set smartindent
au FileType perl set foldlevel=99

" Load boilerplate code
au BufNewFile *.pl 0r ~/.vim/templates/skeleton.pl

" Reopen the last edited position in files
au BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif   

" Enable DiffOrig command:
command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis


let perl_fold=1
let perl_fold_blocks=1

" Statusline
set laststatus=2
set statusline=
set statusline+=\ %*
set statusline+=\ ‹
set statusline+=\ %f\ %*
set statusline+=\ ›
set statusline+=\ %m
set statusline+=\ %F
set statusline+=%=
set statusline+=\ ‹
set statusline+=\ %l
set statusline+=\ ::
set statusline+=\ %v
set statusline+=\ ›\ %*

" Keybindings
vnoremap K :m '<-2<CR>gv=gv				" Move visual block up 
vnoremap J :m '>+1<CR>gv=gv				" Move visual block down 
nnoremap <F4> :set relativenumber!<CR> 	" Relative Numbering
nnoremap () mMI(<esc>A)<esc>`M 			" wrap the current line in (), e.g:
nnoremap )) mMi(<esc>A)<esc>`M 			" wrap the rest of the line in ()
nnoremap (( mMI(<esc>`Mla)<esc> 		" wrap the line so far in ()
noremap cd :call CommentThings() <CR> 	" Keybinding to comment line
noremap <space> zfa{ 					" Bind space to fold between {} in normal mode
nmap <F8> :TagbarToggle<CR>				" Tagbar toggle
nmap " :NERDTreeToggle<CR>				" NerdTree toggle
" End Keybindings

" CtrlSpace mapping
let g:CtrlSpaceDefaultMappingKey = "<C-space> "

" Clear search 
command -nargs=0 CLR let @/ = ''

" Tabline
function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  return bufname(buflist[winnr - 1])
endfunction

set showtabline=2
set tabline=%!MyTabLine()

"let g:seoul256_background = 233
"colo seoul256
colo jellybeans


" Setting folding for bash
""au FileType sh let g:is_bash=1
au FileType sh set foldmethod=syntax
au FileType sh set foldlevel=99
au FileType sh let g:sh_fold_enabled=7

" Function to comment lines
function! CommentThings()
	s/\v(^.*)$/\#\ \1/g
	let @/ = ''
	call cursor( line('.')+1, 1)
endfunction

" Function to fold all perl subroutines
function FoldAllSubs()
	%g/^sub.*{/normal! zf%
	let @/ = ''
	echo "Folded all found subroutines"
endfunction


" Function to fold all bash functions
function FoldAllBash()
	%g/^function.*()\ {/normal! za% " Setting this to za not zf because we can't correctly create folds here, but
	let @/ = ''	" we can fold them each individually after they've been created by fdm=sytax
	echo "Folded all found shell functions" 
endfunction

" }} Fixing syntax highlighting

function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)

" Command for same
command -nargs=0 Foldallperl :call FoldAllSubs()
command -nargs=0 Foldallbash :call FoldAllBash()

" Keybinding for same
au Filetype perl noremap <F6> :call FoldAllSubs() <CR>
au Filetype sh noremap <F6> :call FoldAllBash() <CR>

" Keybinding to comment line
noremap cd :call CommentThings() <CR>

" Bind space to fold between {} in normal mode
noremap <space> zfa{

" Enabling syntax
syntax on

" Setting fg color for folded text
hi Folded ctermfg=181
hi FoldColumn ctermfg=181

" Tagbar apparently?
nmap <F8> :TagbarToggle<CR>
let g:tagbar_iconchars = ['+', '-'] 
set runtimepath^=~/.vim/bundle/tagbar-master/

" neovim QoL Configs:
" So we can actually leave insert mode in nvim term
tnoremap <Esc> <C-\><C-n> 
" Coloring the terminal cursor red
highlight TermCursor ctermfg=red guifg=red

" Needed for vimwiki
set nocompatible
filetype plugin on
