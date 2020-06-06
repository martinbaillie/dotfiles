#!/usr/bin/env zsh
export TZ=Australia/Sydney
export LC_ALL=en_AU.UTF-8
export LANG=en_AU.UTF-8
export LANGUAGE=en_AU.UTF-8

export CLICOLOR=true
export GIT_EDITOR="emacs.bash"
export EDITOR="emacs.bash"
export VISUAL="emacs.bash -n"

# Fuzzing
export FZF_COMPLETION_TRIGGER='~~'
export FZF_DEFAULT_COMMAND='fd --type f -H --follow --no-ignore --exclude .git'
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
export FZF_ALT_C_COMMAND="bfs -type d -nohidden"
export FZF_DEFAULT_OPTS="--multi"
