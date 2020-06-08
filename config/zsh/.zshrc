########################################################################
# Functions.
fpath=( ${ZDOTDIR}/zfuncs "${fpath[@]}" )
autoload -Uz fkill fshow fbranch
typeset -g cdpath fpath mailpath path

# Try to prevent failed commands landing in history.
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

########################################################################
# Plugins.

# Defer init of autopair until after zprezto.
AUTOPAIR_INHIBIT_INIT=1

source "${ZGEN_SRC}/zgen.zsh"
if ! zgen saved; then
  zgen prezto
  zgen load hlissner/zsh-autopair 'autopair.zsh'
  zgen load junegunn/fzf shell
  zgen load chisui/zsh-nix-shell nix-shell.plugin.zsh
  zgen load chriskempson/base16-shell
  zgen load changyuheng/fz
  zgen load rupa/z
  zgen save
fi

# Init the deferred autopair plugin.
autopair-init

# Remove prezto clobber protection.
setopt clobber

# Allow comments on the command line.
setopt interactivecomments

########################################################################
# Look and feel.
THEME="${ZDOTDIR}/theme.zsh"
if [[ -f "${THEME}" ]]; then
  source "${THEME}"
fi

# Dir colours.
if [[ -f "${XDG_CONFIG_HOME}/dircolors/current" ]]; then
    if hash dircolors 2>/dev/null
    then
        eval $(dircolors -b ${XDG_CONFIG_HOME}/dircolors/current)
    else if hash gdircolors 2>/dev/null
        eval $(gdircolors -b ${XDG_CONFIG_HOME}/dircolors/current)
    fi
fi

# Titles and spacing.
case ${TERM} in
  screen*)
    precmd(){
      # Restore tmux-title to 'zsh'
      printf "\033kzsh\033\\"
      # Restore urxvt-title to 'zsh'
      print -Pn "\e]2;zsh:%~\a"
    }
    ;;
  xterm*|rxvt*)
    precmd () {
      if [ ! -n "${INSIDE_EMACS}" ]; then
        print -Pn "\e]0;%n@%m: %~\a"
      fi
    }
    ;;
esac

########################################################################
# Tool-specific RCs.
for file in ${ZDOTDIR}/rc.d/rc.*.zsh(N); do
  source ${file}
done

########################################################################
# Input.
set -o vi
emacs-command-line() { VISUAL=${EDITOR} edit-command-line }
zle -N emacs-command-line
bindkey -M vicmd v emacs-command-line

########################################################################
# Local.
if [[ -f "${XDG_DATA_HOME}/zsh/.zshrc" ]]; then
  source "${XDG_DATA_HOME}/zsh/.zshrc"
fi
