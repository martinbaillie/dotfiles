{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.editors.vim;
in
{
  options.modules.editors.vim = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [ editorconfig-core-c neovim ];

    modules.shell.zsh.aliases = {
      vi = "nvim";
      vim = "nvim";
    };

    modules.shell.zsh.env.VIMINIT =
      "let \\$RC='\\$XDG_CONFIG_HOME/nvim/init.vim'|source \\$RC";

    home.configFile = {
      "nvim/init.vim".text = ''
        let g:mapleader  = ','
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
        set grepprg=${pkgs.ripgrep}/bin/rg\ --vimgrep
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
        set title titlestring=
        set undofile

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
        " smart up and down
        nnoremap <silent><Down> gj
        nnoremap <silent><Up> gk
        " indenting/dedenting
        vnoremap < <gv
        vnoremap > >gv
      '';
    };
  };
}
