SHELL			:=bash
.SHELLFLAGS 	:=-euo pipefail -c
.ONESHELL: ;
.EXPORT_ALL_VARIABLES: ;
ifndef DEBUG
.SILENT: ;
endif
.DEFAULT_GOAL	:=switch

WORKDIR 	:=$(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
HOSTNAME	?=$(shell hostname)
SYSTEM 		:=$(shell uname -s)

ifdef DEBUG
FLAGS			+=--verbose
FLAGS			+=--show-trace
DEPLOY_FLAGS 	+=--debug-logs
else
NIX_FLAGS 		+=--no-warn-dirty
endif

ifeq ($(SYSTEM),Darwin)
FLAGS			+=--impure
else # NixOS:
FLAGS			+=--option pure-eval no
endif

DEPLOY_FLAGS 	+=--skip-checks

# TODO:
# - Helper for individual input updates:
# nix flake lock --update-input darwin

ifeq ($(SYSTEM),Darwin)
NIX_REBUILD		:=nix build $(NIX_FLAGS) $(FLAGS)
NIX_REBUILD		+=.\#darwinConfigurations.$(HOSTNAME).system
NIX_REBUILD		+=&&
NIX_REBUILD		+=./result/sw/bin/darwin-rebuild $(FLAGS)
else
NIX_REBUILD 	:=sudo -E nixos-rebuild $(FLAGS)
endif
NIX_REBUILD 	+=--flake .\#$(HOSTNAME)

# Make defaults.
all: switch
clean: ; rm -f result
.PHONY: all clean

# Build targets.
switch: 	; $(NIX_REBUILD) switch
rollback: 	; $(NIX_REBUILD) switch --rollback
upgrade: 	; $(NIX_REBUILD) switch --upgrade
.PHONY:		switch rollback upgrade

test: ACTION=$(if $(filter-out Darwin,$(SYSTEM)),test,check)
test: ; $(NIX_REBUILD) $(ACTION)
.PHONY: test

update-flake: ; nix flake update
update-homebrew:
update: update-flake update-homebrew
.PHONY: update-flake update-homebrew update

# Runtime targets.
gc:
ifeq ($(SYSTEM),Darwin)
	brew bundle cleanup --zap -f
endif
	nix-collect-garbage -d
.PHONY:	gc

# Remote deploy targets.
deploy-zuul: ; sudo nixos-rebuild switch --flake '.#zuul' --target-host mbaillie@zuul --build-host localhost --impure
deploy-naptime: ; sudo nixos-rebuild switch --flake '.#naptime' --target-host mbaillie@naptime --build-host localhost --impure
.PHONY: deploy-zuul deploy-naptime

# Emacs configuration.
$(XDG_CONFIG_HOME)/emacs:
	git clone --depth 1 https://github.com/doomemacs/doomemacs $@
# Sadly not everything in the Emacs world is supporting XDG yet.
	ln -sf $@ $(HOME)/.emacs.d
$(XDG_CONFIG_HOME)/doom: ; ln -sf $(WORKDIR)/config/emacs $@

config-emacs: $(XDG_CONFIG_HOME)/doom $(XDG_CONFIG_HOME)/emacs ; doom install
.PHONY: config-emacs

# Theme targets.
$(XDG_DATA_HOME)/theme.nix:
ifndef NIX_THEME
	$(error ERROR: NIX_THEME missing)
endif
	echo "{ modules.theme.mode = \"$(NIX_THEME)\"; }" > $@

nix-switch-theme: $(XDG_DATA_HOME)/theme.nix $(NIX_THEME) switch
.PHONY: nix-switch-theme

################################################################################
# Leftover imperative commands needed after a Nix theme switch.
#
# It is surprisingly difficult to programmatically change a macOS background
# across all spaces!
darwin-wallpaper: WALLPAPER ?=$(XDG_CONFIG_HOME)/wallpaper
darwin-wallpaper:
	osascript \
		-e 'tell application "System Events"' \
		-e 'set picture of every desktop to POSIX file "'$(WALLPAPER)'"' \
		-e 'end tell' &
.PHONY: darwin-wallpaper

# light: EMACS_THEME ?=doom-solarized-light
# light: TERM_THEME ?=base16-solarized-light.sh
light: EMACS_THEME ?=modus-operandi
light: TERM_THEME ?=base16-tomorrow.sh
light:
ifeq ($(SYSTEM),Darwin)
light: darwin-wallpaper
	osascript \
		-e 'tell application "System Events"' \
		-e 'tell appearance preferences' \
		-e 'set dark mode to false' \
		-e 'end tell' \
		-e 'end tell' &
endif
ifeq ($(SYSTEM),Linux)
	ln -sf $(ZGEN_DIR)/chriskempson/base16-shell-master/scripts/$(TERM_THEME) \
		$(ZDOTDIR)/theme.zsh
	emacsclient -a "" -n -e "(mb/set-wallpaper)" &>/dev/null
endif
	echo "(setq doom-theme '$(EMACS_THEME))" >$(XDG_CONFIG_HOME)/doom/+theme.el
	emacsclient -a "" -n \
		-e "(setq doom-theme '$(EMACS_THEME))" \
		-e "(doom/reload-theme)" \
		&>/dev/null
.PHONY: light

dark: EMACS_THEME ?=doom-dracula
dark: TERM_THEME ?=base16-dracula.sh
dark:
ifeq ($(SYSTEM),Darwin)
dark: darwin-wallpaper
	osascript \
		-e 'tell application "System Events"' \
		-e 'tell appearance preferences' \
		-e 'set dark mode to true' \
		-e 'end tell' \
		-e 'end tell' &
endif
ifeq ($(SYSTEM),Linux)
	ln -sf $(ZGEN_DIR)/chriskempson/base16-shell/___/scripts/$(TERM_THEME) \
		$(ZDOTDIR)/theme.zsh
	emacsclient -a "" -n \
		-e "(progn (mb/set-wallpaper) (mb/start-panel))" \
		&>/dev/null
endif
	echo "(setq doom-theme '$(EMACS_THEME))" >$(XDG_CONFIG_HOME)/doom/+theme.el
ifeq ($(SYSTEM),Darwin)
	echo "(add-to-list 'default-frame-alist '(ns-appearance . dark))" \
		>>$(XDG_CONFIG_HOME)/doom/+theme.el
endif
	emacsclient -a "" -n \
		-e "(progn (setq doom-theme '$(EMACS_THEME)) (doom/reload-theme))" \
		&>/dev/null
.PHONY: dark
