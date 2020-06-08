#!/usr/bin/env zsh
fzf-file-open-widget() {
  eval "${FZF_CTRL_T_COMMAND}" | $(__fzfcmd) -1 | read file
  [ -n "${file}" ] && v "${file}"
}

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

zle -N fzf-file-open-widget
bindkey '\C-f' fzf-file-open-widget
bindkey '\C-p' fzf-cd-widget
