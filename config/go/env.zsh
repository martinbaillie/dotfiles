#!/usr/bin/env zsh
export GOPATH=$HOME/Code/go
export GOOS=$(uname -s | tr '[:upper:]' '[:lower:]')
export PATH="$GOPATH/bin:$PATH"
