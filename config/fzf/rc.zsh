#!/usr/bin/env zsh
# DEPRECATED. Try `ijq`.
fzf-jq() {
  local input=${1:-}
  if [[ -p /dev/stdin ]]; then
    local tmpfile=$(mktemp "$(basename $0).$$.tmp.XXXXXX")
    cat /dev/stdin >"$tmpfile"
    input="$tmpfile"
  fi
  command cat "$input" | \
    fzf --ansi --multi --preview "command cat '$input' | \
    jq -C {q}" --preview-window 'down:70%' --height '80%' --print-query
  [[ -e "$tmpfile" ]] && rm -f "$tmpfile"
}

# Don't group completions.
zstyle ':completion:*' format ''

# Filename colouring.
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Case insensitive completions.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
