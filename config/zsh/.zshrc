########################################################################
# Functions (incl. completions).
autoload -Uz fkill fshow fbranch

fpath+=${ZDOTDIR}/zfuncs
for profile in ''${(z)NIX_PROFILES}; do
  fpath+=$profile/share/zsh/site-functions
  fpath+=$profile/share/zsh/${ZSH_VERSION}/functions
  fpath+=$profile/share/zsh/vendor-completions
done

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

########################################################################
# Plugins.

# Defer init of autopair until after zprezto.
AUTOPAIR_INHIBIT_INIT=1

# Async fish-like autosuggestion.
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=true

# Load zgen(om) plugin manager.
ZGEN_RESET_ON_CHANGE=(${ZDOTDIR}/.zshrc ${XDG_DATA_HOME}/zsh/.zshrc)
source "${ZGEN_SRC}/zgenom.zsh"

# Load various plugins I've grown used to over the years.
if ! zgenom saved; then
  zgenom prezto
  zgenom load hlissner/zsh-autopair 'autopair.zsh'
  zgenom load junegunn/fzf shell
  zgenom load chisui/zsh-nix-shell nix-shell.plugin.zsh
  zgenom load chriskempson/base16-shell
  zgenom load aperezdc/zsh-fzy
  zgenom load changyuheng/fz
  zgenom load rupa/z
  zgenom load Aloxaf/fzf-tab
  zgenom save
fi

# Compile.
# TODO: PR comp fixes to upstream.
zgenom compile ${ZDOTDIR}/.zshenv
zgenom compile ${ZDOTDIR}/.zprofile
zgenom compile ${ZDOTDIR}/.zshrc
zgenom compile ${ZDOTDIR}/.zlogin
zgenom compile ${ZDOTDIR}/.zlogout
zgenom compile ${ZDOTDIR}/.zcompdump

# Init the deferred autopair plugin.
autopair-init

# Remove prezto clobber protection.
setopt clobber

# Allow comments on the command line.
setopt interactivecomments

# Remove superfluous blanks before adding to history.
setopt histreduceblanks

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
    precmd() {
      if [ ! -n "${INSIDE_EMACS}" ]; then
        print -Pn "\e]0;%n@%m: %~\a"
      fi
    }
    ;;
esac

########################################################################
# Input.
set -o vi
bindkey -M vicmd v edit-command-line

########################################################################
# Tool-specific RCs.
for file in ${ZDOTDIR}/rc.d/rc*.zsh(N); do
  source ${file}
done

########################################################################
# Local.
if [[ -f "${XDG_DATA_HOME}/zsh/.zshrc" ]]; then
  source "${XDG_DATA_HOME}/zsh/.zshrc"
fi
