#!/usr/bin/env zsh
ediff() { emacsclient -u -q -e "(ediff-files \"$1\" \"$2\")"; }
eman() { emacsclient -u -q -e "(man \"$*\")"; }

if [ -n "${INSIDE_EMACS}" ]; then
  # Clear the Emacs buffer.
  alias clear='vterm_printf "51;Evterm-clear";tput clear'

  # Use Emacs for diff and man.
  alias diff=ediff
  alias man=eman

  # Add a visual alias.
  alias v=${VISUAL}
fi

# Make the prompt somewhat evil.
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^U" kill-whole-line
bindkey "^Y" yank
