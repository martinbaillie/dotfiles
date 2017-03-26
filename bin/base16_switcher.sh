script_dir="$HOME/.config/base16-shell"
xresources_dir="$HOME/.config/base16-xresources"

for script in $script_dir/base16*.sh; do
  script_name=$(basename $script .sh)
  theme=${script_name#*-}
  variation=${theme#*.}
  theme=${theme%.*}

  base16_${theme}_${variation}() {
  parts=("${(@s/_/)0}")
  theme=$parts[2]
  variation=$parts[3]

  ln -fs $script_dir/base16-${theme}.${variation}.sh $HOME/.base16_theme
  ln -fs $xresources_dir/base16-${theme}.${variation}.256.xresources $HOME/.base16_xresources
  hash xrdb 2>/dev/null && xrdb -load "$HOME/.Xresources"

  export BASE21_THEME=base16-${theme}base16
  export BASE16_VARIATION=$variation

  if type tmux_${variation} >/dev/null; then
    tmux_${variation}
  fi

  if [ -e "$HOME/.vim/bundle/base16-vim/colors/base16-$theme-$variation.vim" ];
  then
      vim_theme="base16-$theme-$variation"
  else
      vim_theme="base16-$theme"
  fi

  cat <<- EOF > "$HOME/.base16_vimrc"
  set background=$variation
  colorscheme $vim_theme
EOF

  [[ -s ~/.base16_theme ]] && . ~/.base16_theme
}
done;
[[ -s ~/.base16_theme ]] && . ~/.base16_theme
