#!/usr/bin/env zsh
zstyle :fzy:history show-scores  no
zstyle :fzy:history lines        '20'
zstyle :fzy:history prompt       '> '
zstyle :fzy:history command      fzy-history-default-command

zstyle :fzy:file    show-scores  no
zstyle :fzy:file    lines        '20'
zstyle :fzy:file    prompt       '> '
zstyle :fzy:file    command      fd --type f -H --follow --exclude .git

zstyle :fzy:cd      show-scores  no
zstyle :fzy:cd      lines        '20'
zstyle :fzy:cd      prompt       '> '
zstyle :fzy:cd      command      bfs -type d -nohidden

zstyle :fzy:proc    show-scores  no
zstyle :fzy:proc    lines        '20'
zstyle :fzy:proc    prompt       '> '
zstyle :fzy:proc    command      fzy-proc-default-command

fzy-edit-widget() {
    emulate -L zsh
    zle -I
    echo "$(__fzy_fsel)" | read file
    [ -n "${file}" ] && emacs.bash --no-wait "${file}"
    zle reset-prompt
}
zle -N fzy-edit-widget

fzy-kill-widget() {
    emulate -L zsh
    zle -I
    kill -9 $(__fzy_psel)
    zle reset-prompt
}
zle -N fzy-kill-widget

bindkey             '^T'         fzy-cd-widget
bindkey             '^F'         fzy-edit-widget
bindkey             '^P'         fzy-kill-widget
