if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
else
    set background=dark
    colorscheme base16-default
endif
if filereadable(expand("$HOME/.vimrc.local"))
  so $HOME/.vimrc.local
endif

set termguicolors
set mouse=a
set noswapfile
set nobackup
set tabpagemax=100

let mapleader = ","

autocmd Filetype html setlocal ts=2 sts=2 sw=2
autocmd Filetype ruby setlocal ts=2 sts=2 sw=2
autocmd Filetype yaml setlocal ts=2 sts=2 sw=2
autocmd FileType latex,tex,md,markdown,text setlocal spell spelllang=en_au

nnoremap Y y$
nnoremap J mzJ`z

noremap <c-e> :VimFiler -buffer-name=explorer -split -simple -winwidth=35 -toggle -quit<cr>
noremap <c-f> :TagbarToggle<cr>
noremap <c-g> :Goyo<cr>

nmap <leader>x :BD<cr>
nmap <silent> <leader>/ :nohlsearch<cr>
nmap <leader>n :CtrlPBuffer<cr>
nmap <leader>m :CtrlPMRU<cr>
nmap ]h <Plug>GitGutterNextHunk
nmap [h <Plug>GitGutterPrevHunk

let g:spacevim_default_indent = 3
let g:spacevim_max_column     = 80
let g:spacevim_plugin_bundle_dir = '~/.cache/vimfiles/'
let g:spacevim_plugin_manager = 'dein'
let g:spacevim_windows_leader = 's'
let g:spacevim_unite_leader = 'f'

call SpaceVim#layers#load('lang#go')
call SpaceVim#layers#load('lang#java')
call SpaceVim#layers#load('lang#xml')
call SpaceVim#layers#load('format')
call SpaceVim#layers#load('operator')
call SpaceVim#layers#load('ui')

autocmd VimEnter * GitGutterEnable

let g:spacevim_disabled_plugins=[
    \ ['junegunn/fzf.vim'],
    \ ['mhinz/vim-signify'],
    \ ['junegunn/fzf.vim'],
    \ ]

let g:spacevim_custom_plugins = [
    \ ['plasticboy/vim-markdown', {'on_ft' : 'markdown'}],
    \ ['wsdjeg/GitHub.vim'],
    \ ['chriskempson/base16-vim'],
    \ ['majutsushi/tagbar'],
    \ ['qpkorr/vim-bufkill'],
    \ ]

let g:tagbar_left = 1
let g:vimfiler_enable_auto_cd=1
