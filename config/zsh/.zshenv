# Control our own destiny.
setopt no_global_rcs

# If we're a Linux TTY, run our WM.
#if [[ "${OSTYPE}" == linux* ]] && [ "$(tty)" = "/dev/tty1" ]; then
#  command startsway 2>/dev/null && startsway
#fi

# If we're Darwin, run the macOS path helper, but put it last.
if [[ "${OSTYPE}" == darwin* ]] && [ -x /usr/libexec/path_helper ]; then
  eval $(/usr/libexec/path_helper -s | sed 's/^PATH=/_PATH=/')
  export PATH="$PATH:$_PATH"
fi

# Always source zprofile regardless of interactive/non-interactive login.
if [ -f "${ZDOTDIR}/.zprofile" ]; then
  source "${ZDOTDIR}/.zprofile"
fi
