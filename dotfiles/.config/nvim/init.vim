if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

" UI & Themes
Plug 'drewtempelmeyer/palenight.vim'
Plug 'itchyny/lightline.vim'
Plug 'rakr/vim-two-firewatch'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" File Navigation & Search (FZF Integration!)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'

" Language Support
Plug 'othree/html5.vim'
Plug 'othree/yajs.vim'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'

" Git Integration
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Code Quality & Editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'
Plug 'dense-analysis/ale'

" AI Assistant
Plug 'github/copilot.vim'
" Note: Full Copilot Chat requires Neovim. For Vim, use basic Copilot features
" Or consider switching to Neovim for full agent experience

" File Management
Plug 'preservim/tagbar'

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
set guicursor=
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
" Fallback colorscheme setup with error handling
try
  colorscheme two-firewatch
  let g:two_firewatch_italics=1
  let g:airline_theme='twofirewatch'
catch /^Vim\%((\a\+)\)\=:E185/
  " Fallback to a built-in colorscheme if two-firewatch is not available
  colorscheme default
endtry
"

try
  colorscheme palenight
  let g:lightline = { 'colorscheme': 'palenight' }
  let g:airline_theme = "palenight"
catch /^Vim\%((\a\+)\)\=:E185/
  " Fallback to a built-in colorscheme if palenight is not available
  colorscheme default
  let g:lightline = { 'colorscheme': 'default' }
  let g:airline_theme = "dark"
endtry

:highlight Normal ctermbg=236 guibg=#25272a

" =============================================================================
" FZF Configuration (Fuzzy Finding!)
" =============================================================================
" Use FZF for file searching
nnoremap <C-p> :Files<CR>
nnoremap <C-f> :Rg<CR>
nnoremap <C-b> :Buffers<CR>
nnoremap <C-h> :History<CR>
nnoremap <Leader>l :Lines<CR>
nnoremap <Leader>t :Tags<CR>

" FZF window settings
let g:fzf_preview_window = 'right:50%'
let g:fzf_layout = { 'down': '40%' }

" Custom FZF colors to match your theme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" =============================================================================
" Key Mappings & Shortcuts
" =============================================================================
" Set leader key
let mapleader = ","

" NERDTree toggle
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <Leader>n :NERDTreeFind<CR>

" Tagbar toggle
nnoremap <F8> :TagbarToggle<CR>

" Quick save and quit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>x :wq<CR>

" Buffer navigation
nnoremap <Leader>bn :bnext<CR>
nnoremap <Leader>bp :bprev<CR>
nnoremap <Leader>bd :bdelete<CR>

" Window navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" =============================================================================
" Plugin Configuration
" =============================================================================
" ALE (Linting)
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint', 'tsserver'],
\   'python': ['flake8'],
\   'sh': ['shellcheck']
\}
let g:ale_sign_error = '❌'
let g:ale_sign_warning = '⚠️'

" GitGutter
let g:gitgutter_sign_added = '+'
let g:gitgutter_sign_modified = '~'
let g:gitgutter_sign_removed = '-'

" NERDTree
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.DS_Store$', '\.git$', 'node_modules']

" Auto-pairs
let g:AutoPairsShortcutToggle = '<Leader>ap'

" =============================================================================
" GitHub Copilot Configuration
" =============================================================================
" Accept suggestions with Tab (default)
" Alternative: use Ctrl+Y to accept
" imap <silent><script><expr> <C-Y> copilot#Accept("\<CR>")
" let g:copilot_no_tab_map = v:true

" Enable/disable Copilot for specific filetypes
let g:copilot_filetypes = {
    \ 'gitcommit': v:true,
    \ 'markdown': v:true,
    \ 'yaml': v:true
    \ }

" Copilot key mappings
nnoremap <Leader>ce :Copilot enable<CR>
nnoremap <Leader>cd :Copilot disable<CR>
nnoremap <Leader>cs :Copilot status<CR>
nnoremap <Leader>cp :Copilot panel<CR>
