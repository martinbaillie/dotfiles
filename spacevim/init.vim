let mapleader=","

"
" spacevim
" 
let g:spacevim_max_column=80

" call SpaceVim#layers#load('lang#go')
" call SpaceVim#layers#load('lang#xml')
" call SpaceVim#layers#load('lang#markdown')
" call SpaceVim#layers#load('lang#tmux')
" call SpaceVim#layers#load('lang#sh')
" call SpaceVim#layers#load('format')
" call SpaceVim#layers#load('ui')
" call SpaceVim#layers#load('shell')
" call SpaceVim#layers#load('tmux')

"
" plugins
"
let g:spacevim_disabled_plugins=[
    \ ['mhinz/vim-signify'],
    \ ['mhinz/vim-startify'],
    \ ['vim-chat/vim-chat'],
    \ ]

" \ ['plasticboy/vim-markdown', {'on_ft' : 'markdown'}],
    " \ ['davinche/godown-vim', {'on_ft' : 'markdown'}],

let g:spacevim_custom_plugins = [
    \ ['wsdjeg/GitHub.vim'],
    \ ['chriskempson/base16-vim'],
    \ ['majutsushi/tagbar'],
    \ ['qpkorr/vim-bufkill'],
    \ ['pbogut/fzf-mru.vim'],
    \ ['junegunn/fzf.vim'],
    \ ['martinda/Jenkinsfile-vim-syntax'],
    \ ['vim-airline/vim-airline-themes'],
    \ ['hashivim/vim-hashicorp-tools'],
    \ ['mbbill/undotree'],
    \ ['christoomey/vim-tmux-navigator'],
    \ ]

"
" plugin settings
"
" tagbar
let g:tagbar_left=1
let g:tagbar_width=30
noremap <c-f> :TagbarToggle<cr>

" goyo and limelight
let g:goyo_width=100
noremap <c-g> :Goyo<cr>

" fzf
let g:fzf_command_prefix = 'FZF'
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)
nnoremap <leader>rg :Rg<space>
nnoremap <leader>n :FZFBuffers<cr>
nnoremap <leader>m :FZFMru<cr>

" markdown/godown 
let g:godown_autorun=1

" bufkill
nmap <leader>x :BD<cr>

" gitgutter
let g:gitgutter_override_sign_column_highlight=1
let g:gitgutter_enabled=1
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

" vimfiler
map <silent> <c-e> :VimFilerBufferDir -toggle<cr>
let g:vimfiler_enable_auto_cd=1
au FileType vimfiler nmap <buffer> <2-LeftMouse> <Plug>(vimfiler_edit_file)

" terraform formatting
let g:terraform_fmt_on_save=1

" undotree
nmap <leader>u :UndotreeToggle<cr>

"
" standard vim settings
"
set clipboard=unnamed
set diffopt=filler,vertical,iwhite
set confirm
set inccommand=split
set ignorecase
set smartcase
set scrolloff=10
set title titlestring=
set mouse=a

"
" standard vim mappings
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
" smart up and down
nnoremap <silent><Down> gj
nnoremap <silent><Up> gk
" indenting/dedenting
vnoremap < <gv
vnoremap > >gv
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
" keep content of register after a paste
function! RestoreRegister()
    let @" = s:restore_reg
    if &clipboard == "unnamed"
        let @* = s:restore_reg
    endif
    return ''
endfunction
function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction
vnoremap <silent> <expr> p <sid>Repl()

au Filetype html,ruby,yaml setlocal ts=2 sts=2 sw=2
au FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au
au FileType text setlocal textwidth=78
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

"
" colours
"
if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
endif

" fix nvim colours inside tmux
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

"
" local settings
"
if filereadable(expand("$HOME/.vimrc.local"))
  so $HOME/.vimrc.local
endif
