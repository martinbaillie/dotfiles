"
" plugins (requires dein to be installed)
"
if &compatible
  set nocompatible
endif
set runtimepath+=$HOME/.config/nvim/dein/repos/github.com/Shougo/dein.vim

if dein#load_state('$HOME/.config/nvim/dein')
  call dein#begin('$HOME/.config/nvim/dein')

  call dein#add('$HOME/.config/nvim/dein/repos/github.com/Shougo/dein.vim')

  call dein#add('mhinz/vim-startify')
  call dein#add('chriskempson/base16-vim')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('qpkorr/vim-bufkill')

  " todo: am i going to use this?
  call dein#add('Shougo/denite.nvim')

  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  call dein#add('junegunn/goyo.vim')
  call dein#add('junegunn/limelight.vim')
  call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 }) 
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
  call dein#add('pbogut/fzf-mru.vim')

  call dein#add('fatih/vim-go', {'on_ft' : 'go'})
  call dein#add('scrooloose/nerdcommenter')
  
  call dein#add('plasticboy/vim-markdown', {'on_ft' : 'markdown'})
  call dein#add('davinche/godown-vim', {'on_ft' : 'markdown'})

  call dein#end()
  call dein#save_state()
endif

"
" system functions
"
silent function! OSX()
	return has('macunix')
endfunction
silent function! NIX()
	return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! WIN()
	return  (has('win16') || has('win32') || has('win64'))
endfunction
if (OSX() || NIX())
  cmap w!! w !sudo tee % >/dev/null
endif

"
" vim settings
"
let mapleader = ","

syntax enable
syntax sync minlines=256
filetype plugin indent on

set shell=bash\ -i
set synmaxcol=200
set lazyredraw
set relativenumber
set termguicolors
set mouse=a
set noswapfile
set nobackup
set tabpagemax=100
set autochdir
set ignorecase
set smartcase
set scrolloff=10
set sidescrolloff=15
set sidescroll=1
set encoding=utf-8

scriptencoding utf-8

set autoindent
set smartindent
set smarttab
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set nofoldenable

autocmd Filetype html,ruby,yaml setlocal ts=2 sts=2 sw=2
autocmd FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au

"
" vim mappings
"
" saving and quitting
noremap <leader>q :q<cr>
nnoremap <leader>w :w<cr>
" clear search with <leader>/
nmap <silent><leader>/ :nohlsearch<cr>
" yank from cursor to EOL
nnoremap Y y$
" stop cursor jumping around while joining lines
nnoremap J mzJ`z
" center after searching
nnoremap n nzz
nnoremap } }zz
nnoremap N Nzz
" enter to bottom, Backspace to top, 12<enter> to 12th line
nnoremap <CR> G
nnoremap <BS> gg
" combine with iterm2 sending esc+c upon mod+c
vnoremap <M-y> "+y

"
" plugin settings
"

" deoplete and neosnippet
let g:deoplete#enable_at_startup = 1
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" goyo and limelight
noremap <c-g> :Goyo<cr>
function! s:goyo_enter()
  set noshowmode
  set noshowcmd
  set scrolloff=999
  Limelight
endfunction
function! s:goyo_leave()
  set showmode
  set showcmd
  set scrolloff=5
  Limelight!
  call <SID>matching_splits()
endfunction
augroup goyo_map
  autocmd! User GoyoEnter nested call <SID>goyo_enter()
  autocmd! User GoyoLeave nested call <SID>goyo_leave()
augroup END

" fzf
let g:fzf_command_prefix = 'FZF'
nmap <leader><space> :FZFBuffers<cr>
nmap <leader>n :FZFFiles<cr>
nmap <leader>m :FZFMru<cr>

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_skip_empty_sections = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_idx_format = {}
function! s:bubble_num(num) abort
  let list = []
  call add(list,['➊', '➋', '➌', '➍', '➎', '➏', '➐', '➑', '➒', '➓'])
  let n = ''
  try
    let n = list[0][a:num-1] 
  catch
  endtry
  return  n
endfunction
for s:i in range(9)
call extend(g:airline#extensions#tabline#buffer_idx_format,
      \ {s:i : s:bubble_num(s:i). ' '})
endfor
unlet s:i
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type= 2
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#buffers_label = 'BUFFERS'
let g:airline#extensions#tabline#tabs_label = 'TABS'
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab

" denite

" markdown/godown 
let g:godown_autorun=1

" bufkill
nmap <leader>x :BD<cr>

"nmap <leader>gt :GoDef<cr>
"nmap ]h <Plug>GitGutterNextHunk
"nmap [h <Plug>GitGutterPrevHunk
"map <silent> <c-e> :NERDTreeToggle %:p:h<cr>
"map <leader>e :NERDTreeToggle %:p:h<cr>
"map <leader>r :NERDTreeFind<cr>

"
" colours
"
if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
else
    set background=dark
    colorscheme base16-default
endif

" TODO: this function seems broken
function! s:matching_splits()
    set foldcolumn=2
    hi LineNr guibg=bg ctermbg=bg
    hi CursorLineNr guibg=bg ctermbg=bg
    hi foldcolumn guibg=bg ctermbg=bg
    hi VertSplit guibg=bg ctermbg=bg guifg=bg ctermfg=bg
endfunction
call s:matching_splits()

"
" gui
"
if has('gui_running')
  autocmd! GUIEnter * set vb t_vb=
  set mousehide
  set guioptions=
  set guicursor+=a:blinkon0

  if WIN()
    au GUIEnter * simalt ~x
    map <F11> <Esc>:call libcallnr("gvimfullscreen.dll", "ToggleFullScreen", 0)<CR>
    so $VIMRUNTIME/mswin.vim
    set guifont=DejaVu_Sans_Mono_for_Powerline:h10:cANSI
elseif (OSX() || NIX())
    if OSX()
        "    set guifont=Inconsolata\ for\ Powerline:h13
        set guioptions-=L
        map <D-CR> :set invfu<CR>
        "set fu
        set clipboard=unnamed
    endif
  endif
endif

"
" local settings
"
if filereadable(expand("$HOME/.vimrc.local"))
  so $HOME/.vimrc.local
endif

"
" check plugin updates
"
if dein#check_install()
  call dein#install()
endif
