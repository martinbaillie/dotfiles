#!/usr/bin/env bash

opts=$1
shift
emacsclient -a "" -n -e "(if (> (length (frame-list)) 0) 't)" | grep -q t
if [ "$?" = "1" ]; then
    emacsclient -q -c -a "" "${opts}" "$@"
else
    emacsclient -q -a "" "${opts}" "$@"
fi

if [[ "$OSTYPE" == darwin* ]]; then
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "Emacs" to activate' 2>/dev/null
    command -v osascript > /dev/null 2>&1 && \
        osascript -e 'tell application "System Events" to tell process "Emacs"
        set frontmost to true
        windows where title contains "Emacs"
        if result is not {} then perform action "AXRaise" of item 1 of result
    end tell' &> /dev/null || exit 0
fi
