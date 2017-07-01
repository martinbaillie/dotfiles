script_dir="$HOME/.config/base16-shell/scripts"

for script in $script_dir/base16*.sh; do
  script_name="$(basename $script .sh)"
  theme=${script_name#*-}
  variation=${theme#*.}
  theme=${theme%.*}

  ${script_name}() {
    parts=("${(@s/_/)0}")
    theme=$parts[1]
    ln -fs $script_dir/${theme}.sh $HOME/.base16_theme
    parts=($(echo $theme | sed -E 's/.*base16-(.*)-(light|dark).*/\1 \2/p'))
    cat <<- EOF > "$HOME/.base16_vimrc"
let g:spacevim_colorscheme='$parts[1]'
let g:spacevim_colorscheme_bg='$parts[2]'
let g:airline_theme='$parts[1]'
EOF
    [[ -s ~/.base16_theme ]] && . ~/.base16_theme
  }
done;

[[ -s ~/.base16_theme ]] && . ~/.base16_theme
