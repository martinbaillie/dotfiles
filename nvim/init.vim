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

  call dein#add('scrooloose/nerdcommenter')
  call dein#add('scrooloose/nerdtree')

  call dein#add('Shougo/deoplete.nvim')
  call dein#add('Shougo/neosnippet.vim')
  call dein#add('Shougo/neosnippet-snippets')

  call dein#add('junegunn/goyo.vim')
  call dein#add('junegunn/limelight.vim')
  call dein#add('junegunn/fzf', { 'build': './install --all', 'merged': 0 }) 
  call dein#add('junegunn/fzf.vim', { 'depends': 'fzf' })
  call dein#add('pbogut/fzf-mru.vim')

  call dein#add('tpope/vim-fugitive')
  call dein#add('airblade/vim-gitgutter')
  call dein#add('neomake/neomake')
  call dein#add('martinda/Jenkinsfile-vim-syntax')

  call dein#add('plasticboy/vim-markdown', {'on_ft' : 'markdown'})
  call dein#add('davinche/godown-vim', {'on_ft' : 'markdown'})
  call dein#add('fatih/vim-go', {'on_ft' : 'go'})

  call dein#end()
  call dein#save_state()
endif

"
" system functions
"
silent fu! OSX()
	return has('macunix')
endf
silent fu! NIX()
	return has('unix') && !has('macunix') && !has('win32unix')
endf
silent fu! WIN()
	return  (has('win16') || has('win32') || has('win64'))
endf
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
set autoindent
set smartindent
set cindent
set smarttab
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set nofoldenable
set noshowcmd
set linebreak
set autoread
set inccommand=split
set hidden
set confirm
set cursorline
set diffopt=filler,vertical,iwhite
set encoding=utf-8
scriptencoding utf-8

au Filetype html,ruby,yaml setlocal ts=2 sts=2 sw=2
au FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au
au BufWinEnter quickfix nnoremap <silent> <buffer>
            \   q :cclose<cr>:lclose<cr>
au BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) |
            \   bd|
            \   q | endif
au BufEnter,WinEnter,InsertLeave * setl cursorline
au BufLeave,WinLeave,InsertEnter * setl nocursorline
au FileType text setlocal textwidth=78
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
au FileType qf setlocal wrap
"au BufWritePost * if &diff == 1 | diffupdate | endif

"
" vim mappings
"
" stop accidentally recording
nnoremap Q q
nnoremap q <Nop>
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
" enter to bottom, backspace to top, 12<enter> to 12th line
nnoremap <CR> G
nnoremap <BS> gg
" combine with iterm2 profile sending esc+c upon mod+y, esc+a on mod+a
vnoremap <M-y> "+y
nnoremap <M-a> ggVG
" tab between
map <silent><TAB> <C-w>w
map <silent><S-TAB> <C-w>p
" smart up and down
nnoremap <silent><Down> gj
nnoremap <silent><Up> gk
" remove spaces at the end of lines
nnoremap <silent> <C-Space> :<C-u>silent! keeppatterns %substitute/\s\+$//e<CR>
" <Esc> to exit terminal-mode:
:tnoremap <Esc> <C-\><C-n>
" diffing
map <leader>d1 :diffget 1<cr>
map <leader>d2 :diffget 2<cr>
map <leader>d3 :diffget 3<cr>
" substitute word under cursor or selection
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

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
  au! User GoyoEnter nested call <SID>goyo_enter()
  au! User GoyoLeave nested call <SID>goyo_leave()
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
fu! s:bubble_num(num) abort
  let list = []
  call add(list,['➊', '➋', '➌', '➍', '➎', '➏', '➐', '➑', '➒', '➓'])
  let n = ''
  try
    let n = list[0][a:num-1] 
  catch
  endtry
  return  n
endf
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

" nerdtree
map <silent> <c-e> :NERDTreeToggle %:p:h<cr>
map <leader>e :NERDTreeToggle %:p:h<cr>
map <leader>r :NERDTreeFind<cr>
let g:NERDTreeWinPos='right'
let g:NERDTreeWinSize=31
let g:NERDTreeChDirMode=1
let g:NERDShutUp=1
let g:NERDTreeShowHidden=1
let g:NERDTreeIgnore=['\.pyc', '\~$', '\.swo$', '\.swp$', '\.git', '\.hg', '\.svn', '\.bzr', '\.\.$', '\.$']
au BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"au BufEnter * if &modifiable | NERDTreeFind | wincmd p | endif

" markdown/godown 
let g:godown_autorun=1

" bufkill
nmap <leader>x :BD<cr>

" gitgutter
let g:gitgutter_override_sign_column_highlight=0
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

" neomake
au! BufWritePost * Neomake
let g:neomake_open_list = 2

" go
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"
let g:go_metalinter_autosave = 1
let g:go_gocode_unimported_packages = 1
nmap <leader>gt :GoDef<cr>

"
" colours
"
if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
else
    set background=dark
    colorscheme base16-default
endif
fu! s:matching_splits()
    set foldcolumn=2
    hi LineNr guibg=bg
    hi CursorLineNr guibg=bg
    hi foldcolumn guibg=bg
    hi VertSplit guibg=bg guifg=bg
    hi GitGutterAdd guibg=bg
    hi GitGutterChange guibg=bg
    hi GitGutterDelete guibg=bg
    hi GitGutterChangeDelete guibg=bg
    hi! link SignColumn LineNr
endf
call s:matching_splits()

"
" gui
"
if has('gui_running')
  au! GUIEnter * set vb t_vb=
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
