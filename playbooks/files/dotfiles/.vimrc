highlight colorcolumn ctermbg=LightGray
highlight GitGutterAdd    cterm=bold ctermfg=33
highlight GitGutterChange cterm=bold ctermfg=136
highlight GitGutterDelete cterm=bold ctermfg=160
highlight Search ctermbg=DarkBlue ctermfg=White
highlight! link SignColumn LineNr
let g:airline_skip_empty_sections = 1
let g:airline_theme='sol'
map <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
set background=light
set backspace=indent,eol,start
set colorcolumn=100
set cursorline
set hlsearch incsearch
set laststatus=2
set linebreak
set mouse=i
set novisualbell noerrorbells
set scrolloff=4
set showmatch
set tabstop=2 shiftwidth=2 expandtab smarttab autoindent
set term=screen-256color
set ttimeoutlen=10
set updatetime=100
syntax on

" use hybrid line numbering by default with automatic toggling
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END
