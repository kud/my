if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/bundle')

Plug 'itchyny/lightline.vim'

call plug#end()

if (has("termguicolors"))
 set termguicolors
endif

syntax enable

colorscheme OceanicNext

set backspace=2
set nu
set showcmd
set noruler
set cursorline
set encoding=utf8
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
