" Display helpful info at the bottom line
set ruler
" Fix backspace
set bs=2
" Auto Indent on
set ai
" Tab = 2 spaces please thanks
set ts=2
" Most of the time I don't like wrapping
set nowrap
" Enable syntax highlighting
syntax on
" Don't highlight search matches
set nohlsearch
" Don't fill tabs anymore. Keep things the way they are
" Use :retab 2 to undo my own tab damage!
"set expandtab
" Magic to return to previous position in file
au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g'\"" | endif
" Amount of history to store
set viminfo='20,\"50
set history=50 
" My background is dark so display light colours please thanks
set background=dark
source ~/.vim/vis.vim

let g:html_tag_case = 'lowercase'
let g:no_html_tab_mapping = 1
source ~/.vim/HTML.vim
HTML off

set spelllang=en,nl
set spellfile=~/.vim/spell/taal.latin1.add
setlocal spell spelllang=en,nl

let loaded_matchparen = 1

" Yes modelines please
"set modelines=1
"set modeline
" Well use secure ones instead
    
let g:secure_modelines_allowed_items = [
            \ "wrap",
            \ "textwidth",   "tw",
            \ "softtabstop", "sts",
            \ "tabstop",     "ts",
            \ "shiftwidth",  "sw",
            \ "expandtab",   "et",   "noexpandtab", "noet",
            \ "filetype",    "ft",
            \ "foldmethod",  "fdm",
            \ "readonly",    "ro",   "noreadonly", "noro",
            \ "rightleft",   "rl",   "norightleft", "norl",
            \ "spell",
            \ "spelllang"
            \ ]
source ~/.vim/securemodelines.vim

" ttymouse interferes with screen + vim middle mouse click paste
set ttymouse=
