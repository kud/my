if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

Plug 'drewtempelmeyer/palenight.vim'
Plug 'itchyny/lightline.vim'
Plug 'othree/html5.vim'
Plug 'othree/yajs.vim'
Plug 'rakr/vim-two-firewatch'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


call plug#end()

syntax enable

if (has("termguicolors"))
 set termguicolors
endif

set backspace=2
set nu
set showcmd
set noruler
set cursorline
set encoding=utf-8
set expandtab
set showmode
set number
set hidden
set laststatus=2
set nohlsearch
set incsearch
set ignorecase
set smartcase
set mouse=a
set background=dark

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

"
colorscheme two-firewatch
let g:two_firewatch_italics=1
let g:airline_theme='twofirewatch'
"

colorscheme palenight
let g:lightline = { 'colorscheme': 'palenight' }
let g:airline_theme = "palenight"

:highlight Normal ctermbg=236 guibg=#25272a
