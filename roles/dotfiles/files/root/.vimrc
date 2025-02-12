hi colorcolumn ctermbg=LightMagenta guibg=LightMagenta
hi Search ctermbg=DarkBlue ctermfg=White
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
