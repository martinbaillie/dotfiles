#!/usr/bin/env zsh
alias e=$EDITOR
alias v=$VISUAL

unalias gb 2>/dev/null || true
unalias la 2>/dev/null || true
unalias gls 2>/dev/null || true

alias mkdir='mkdir -p'
alias cat='bat -p'
alias wget='wget -c'
alias bc='bc -lq'
alias rg='rg --hidden'
alias tree="tree -a -I '.git'"

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

if command -v exa >/dev/null; then
  alias exa='exa -h --group-directories-first --git'
  alias ls=exa
  alias l='exa -1a'
  alias ll='exa -la'
  alias lt='exa -lm -s modified'
else
  alias l='ls -1a'
  alias ll='ls -la'
fi

if command -v nvim >/dev/null; then
  alias vim=nvim
  alias vi=nvim
fi
