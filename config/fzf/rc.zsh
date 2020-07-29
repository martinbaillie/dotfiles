#!/usr/bin/env zsh
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
