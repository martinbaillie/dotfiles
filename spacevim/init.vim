if filereadable(expand("$HOME/.base16_vimrc"))
    so $HOME/.base16_vimrc
else
    set background=dark
    colorscheme base16-default
endif
if filereadable(expand("$HOME/.vimrc.local"))
  so $HOME/.vimrc.local
endif

set mouse=a
"set list listchars=tab:\ \ ,trail:·
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

noremap <c-e> :VimFiler<CR>
noremap <c-f> :TagbarToggle<CR>

nmap <leader>x :BD<cr>
nmap <silent> <leader>/ :nohlsearch<CR>
nmap <leader>n :CtrlPBuffer<cr>
nmap <leader>m :CtrlPMRU<cr>

let g:spacevim_default_indent = 3
let g:spacevim_max_column     = 80
let g:spacevim_plugin_bundle_dir = '~/.cache/vimfiles/'
let g:spacevim_plugin_manager = 'dein'  " neobundle or dein or vim-plug
let g:spacevim_windows_leader = 's'
let g:spacevim_unite_leader = 'f'

call SpaceVim#layers#load('lang#go')
call SpaceVim#layers#load('ui')

let g:spacevim_disabled_plugins=[
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
