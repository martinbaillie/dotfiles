let g:mapleader  = ','

" plugins (requires vim-plug to be installed)
"
call plug#begin('~/.config/nvim/plugged')
Plug 'takac/vim-hardtime'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'chaoren/vim-wordmotion'
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'haya14busa/vim-easyoperator-line'
Plug 'Shougo/vimfiler.vim'
Plug 'Shougo/unite.vim'
Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'rust-lang/rust.vim'
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
Plug 'sjl/vitality.vim'
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'mtth/cursorcross.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'benmills/vimux'
Plug 'machakann/vim-highlightedyank'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-fugitive'
"Plug 'jreybert/vimagit'
Plug 'scrooloose/nerdcommenter'
Plug 'neomake/neomake'
Plug 'leafgarland/typescript-vim'
Plug 'martinbaillie/vim-remarkjs'
Plug 'idbrii/vim-gogo'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-line'
Plug 'kana/vim-textobj-entire'
Plug 'ryanoasis/vim-devicons'
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
let g:expand_region_text_objects = {
      \ 'iw'  :0,
      \ 'iW'  :0,
      \ 'i"'  :0,
      \ 'i''' :0,
      \ 'i]'  :1,
      \ 'ib'  :1,
      \ 'iB'  :1,
      \ 'il'  :1,
      \ 'ii'  :1,
      \ 'ip'  :0,
      \ 'ie'  :1,
      \ }

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

" incsearch and easymotion
function! s:config_easyfuzzymotion(...) abort
  return extend(copy({
  \   'converters': [incsearch#config#fuzzyword#converter()],
  \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
  \   'keymap': {"\<CR>": '<Over>(easymotion)'},
  \   'is_expr': 0,
  \   'is_stay': 1
  \ }), get(a:, 1, {}))
endfunction
map / <Plug>(incsearch-easymotion-/)
map ? <Plug>(incsearch-easymotion-?)
map g/ <Plug>(incsearch-easymotion-stay)
"map <c-w> <Plug>(easymotion-prefix)
map f <Plug>(easymotion-prefix)

" goyo and limelight
let g:goyo_width=100
noremap <c-g> :Goyo<cr>
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
nnoremap <silent><leader>l :Limelight!<cr>

" hardtime
let g:hardtime_default_on = 1
let g:hardtime_ignore_quickfix = 1
let g:hardtime_timeout = 1000
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 5
map <silent><leader>h :HardTimeToggle<cr>

" gitgutter
let g:gitgutter_override_sign_column_highlight=1
let g:gitgutter_enabled=1
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

" cursorcross
let g:cursorcross_dynamic='clw'
let g:cursorcross_mappings=1

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

" markdown previews
"let g:mkdp_auto_start = 1

" :CocInstall coc-json coc-html coc-css coc-gocode coc-neosnippet coc-yaml
" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" golang
let g:go_metalinter_command="golangci-lint"

autocmd FileType go nmap gt  <Plug>(go-test)
autocmd FileType go nmap ga  :GoAlternate<cr>
autocmd FileType go nmap gc  :GoCoverage<cr>
autocmd FileType go nmap gi  :GoInfo<cr>
autocmd FileType go nmap gm  :GoMetaLinter<cr>
autocmd FileType go set colorcolumn=100

" rust
let g:rustfmt_autosave = 1

let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"
let g:go_snippet_engine = "neosnippet"
let g:go_metalinter_deadline = "60s"
"let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_autosave = 0
let g:go_test_show_name = 1
let g:go_list_type = "quickfix"
let g:go_echo_command_info = 1

" neomake
call neomake#configure#automake('w')

let g:neomake_open_list = 2
"let g:neomake_highlight_columns = 1
"let g:neomake_highlight_lines = 1
let g:neomake_go_enabled_makers = [ 'go', 'golint', 'govet' ]
let g:neomake_proto_enabled_makers = [ 'prototool' ]

" protobuffers
function! PrototoolFormat() abort
    silent! execute '!prototool format -w %'
    silent! edit
endfunction
autocmd BufEnter,BufWritePost *.proto :call PrototoolFormat()

" undotree
nmap <leader>u :UndotreeToggle<cr>

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
" buffer next and prev
"nmap <silent><tab> :bn<cr>
"nmap <silent><S-tab> :bp<cr>
  
" filetype specific settings
au Filetype html,ruby,yaml setlocal ts=2 sts=2 sw=2
au FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au
au FileType text setlocal textwidth=78
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

let g:rooter_patterns = ['Dockerfile', 'Makefile', 'go.mod', 'Cargo.toml', 'Rakefile', '.git/']
let g:rooter_silent_chdir = 1

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
