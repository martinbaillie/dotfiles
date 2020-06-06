#!/usr/bin/env zsh
export FZF_COMPLETION_TRIGGER='~~'
export FZF_DEFAULT_COMMAND='fd --type f -H --follow --no-ignore --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND="bfs -type d -nohidden"
export FZF_DEFAULT_OPTS="--multi"
