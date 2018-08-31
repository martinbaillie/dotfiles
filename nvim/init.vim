let g:mapleader  = ','

"
" plugins (requires vim-plug to be installed)
"
call plug#begin('~/.config/nvim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/unite.vim'
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'mdempsky/gocode', { 'rtp': 'nvim', 'do': '~/.config/nvim/plugged/gocode/nvim/symlink.sh' }
Plug 'junegunn/fzf', { 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'majutsushi/tagbar'
Plug 'hashivim/vim-hashicorp-tools'
Plug 'mbbill/undotree'
Plug 'terryma/vim-expand-region'
Plug 'qpkorr/vim-bufkill'
Plug 'szw/vim-smartclose'
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'
Plug 'machakann/vim-highlightedyank'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/nerdcommenter'
Plug 'neomake/neomake'
Plug 'sbdchd/neoformat'
call plug#end()

"
" plugin settings
"

" vimfiler
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_restore_alternate_file =1
let g:vimfiler_tree_indentation = 1
let g:vimfiler_tree_leaf_icon = ''
let g:vimfiler_tree_opened_icon = '▼'
let g:vimfiler_tree_closed_icon = '▷'
let g:vimfiler_file_icon =''
let g:vimfiler_readonly_file_icon ='*'
let g:vimfiler_marked_file_icon = '√'
let g:vimfiler_direction = 'rightbelow'
let g:vimfiler_ignore_pattern='^\%(\.git\|\.DS_Store\)$'
call vimfiler#custom#profile('default', 'context', {
      \ 'explorer' : 1,
      \ 'winwidth' : 25,
      \ 'winminwidth' : 20,
      \ 'toggle' : 1,
      \ 'auto_expand': 1,
      \ 'direction' : g:vimfiler_direction,
      \ 'explorer_columns' : '',
      \ 'parent': 0,
      \ 'status' : 1,
      \ 'safe' : 0,
      \ 'split' : 1,
      \ 'hidden': 1,
      \ 'no_quit' : 1,
      \ 'force_hide' : 0,
      \ })
autocmd FileType vimfiler call s:vimfilerinit()
function! s:vimfilerinit()
  setl nonumber
  setl norelativenumber
  nmap <buffer> <Tab>   <Plug>(vimfiler_switch_to_other_window)
  nmap <buffer> <C-r>   <Plug>(vimfiler_redraw_screen)
  nmap <buffer> <Left>  <Plug>(vimfiler_smart_h)
  nmap <buffer> <Right> <Plug>(vimfiler_smart_l)
endf
map <silent> <leader>e :VimFilerBufferDir<cr>

" expand region
xmap v <Plug>(expand_region_expand)
xmap V <Plug>(expand_region_shrink)

" fzf
let g:fzf_command_prefix = 'FZF'
command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)
nnoremap ff :Rg<cr>
nnoremap <leader>n :FZFBuffers<cr>
nnoremap <leader>m :FZFFreshMru<cr>
nnoremap <leader><space> :FZFLines<cr>
nnoremap <c-e> :FZF<cr>

" bufkill
nmap <leader>x :BD<cr>

" smart close
nnoremap <silent>q :SmartClose<cr>

" highlighted yanks
let g:highlightedyank_highlight_duration=200

" vimux
map <leader>vp :VimuxPromptCommand<CR>
map <leader>vl :VimuxRunLastCommand<CR>

" goyo and limelight
let g:goyo_width=100
noremap <c-g> :Goyo<cr>

" gitgutter
let g:gitgutter_override_sign_column_highlight=1
let g:gitgutter_enabled=1
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

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
let g:airline#extensions#tabline#buffers_label = ''
let g:airline#extensions#tabline#tabs_label = ''
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

" tagbar
let g:tagbar_left=1
let g:tagbar_width=30
noremap <c-f> :TagbarToggle<cr>

" terraform formatting
let g:terraform_fmt_on_save=1

" deoplete
let g:deoplete#enable_at_startup = 1
" deoplete-go 
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#gocode_binary=$GOPATH.'/bin/gocode'
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1

" golang
autocmd FileType go nmap gt  <Plug>(go-test)
autocmd FileType go nmap ga  :GoAlternate<cr>
autocmd FileType go nmap gi  :GoInfo<cr>
autocmd FileType go set colorcolumn=100

" undotree
nmap <leader>u :UndotreeToggle<cr>

" neomake
" when writing a buffer (no delay), and on normal mode changes (after 750ms)
call neomake#configure#automake('nw', 750)
let g:neomake_open_list = 2

" ================
" system functions
" ================
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

" =====================
" standard vim settings
" =====================
syntax sync minlines=256
set autochdir
set autoindent
set autoread
set cindent
set clipboard=unnamed
set completeopt+=noinsert
set completeopt+=noselect
set confirm
set cursorline
set diffopt=filler,vertical,iwhite
set encoding=utf-8
set expandtab
set grepprg=rg\ --vimgrep
set hidden
set ignorecase
set inccommand=split
set lazyredraw
set linebreak
set mouse=a
set nobackup
set nofoldenable
set noshowcmd
set noswapfile
set relativenumber
set scrolloff=10
set shell=bash\ -i
set shiftwidth=4
set shortmess+=T
set sidescroll=1
set sidescrolloff=15
set smartcase
set smartindent
set smarttab
set softtabstop=4
set synmaxcol=200
set tabpagemax=100
set tabstop=4
set termguicolors
set title titlestring=
set undofile

" =====================
" standard vim mappings
" =====================
" stop accidentally recording
nnoremap Q <Nop>
" saving and quitting
noremap <leader>q :q<cr>
nnoremap <leader>w :w<cr>
nnoremap <C-s> :w<cr>
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
" smart up and down
nnoremap <silent><Down> gj
nnoremap <silent><Up> gk
" indenting/dedenting
vnoremap < <gv
vnoremap > >gv
" remove spaces at the end of lines
nnoremap <silent> <C-Space> :<C-u>silent! keeppatterns %substitute/\s\+$//e<CR>
" diffing
map <leader>d1 :diffget 1<cr>
map <leader>d2 :diffget 2<cr>
map <leader>d3 :diffget 3<cr>
" substitute word under cursor or selection
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>
  
" filetype specific settings
au Filetype html,ruby,yaml setlocal ts=2 sts=2 sw=2
au FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au
au FileType text setlocal textwidth=78
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

" autochdir doesn't work with some plugins
au BufEnter * silent! lcd %:p:h

" autoreload vim settings upon save
augroup vimrc 
    autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded settings from " . $MYVIMRC | redraw
augroup END

" =======
" colours
" =======
if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
else
    set background=dark
    colorscheme base16-default
endif
hi LineNr guibg=bg
hi foldcolumn guibg=bg
hi VertSplit guibg=bg guifg=bg

" ==============
" local settings
" ==============
if filereadable(expand("$HOME/.vimrc.local"))
  so $HOME/.vimrc.local
endif