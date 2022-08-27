call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

Plug 'arcticicestudio/nord-vim'

call plug#end()


set number
syntax on
colorscheme nord

inoremap jj <ESC>

