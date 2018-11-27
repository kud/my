if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

Plug 'itchyny/lightline.vim'
Plug 'othree/yajs.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'othree/html5.vim'
Plug 'scrooloose/nerdtree'

call plug#end()

syntax enable

if (has("termguicolors"))
 set termguicolors
endif

colorscheme OceanicNext

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

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
