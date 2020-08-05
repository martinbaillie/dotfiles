SHELL 			:=bash
.SHELLFLAGS 	:=-euo pipefail -c
.ONESHELL: ;
.EXPORT_ALL_VARIABLES: ;
ifndef DEBUG
.SILENT: ;
endif
.DEFAULT_GOAL	:=switch

WORKDIR 	:=$(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
HOSTNAME	:=$(shell hostname -s)
SYSTEM 		:=$(shell uname -s)

# General dependencies.
DARWIN_REBUILD ?=$(if $(shell which darwin-rebuild 2>/dev/null),\
	$(shell which darwin-rebuild),/run/current-system/sw/bin/darwin-rebuild)
$(DARWIN_REBUILD): URL=https://github.com/LnL7/nix-darwin/archive/master.tar.gz
$(DARWIN_REBUILD):
	nix-build $(URL) -A installer
	yes | ./result/bin/darwin-installer

BREW ?=$(if $(shell which brew 2>/dev/null),\
	$(shell which brew),/usr/local/bin/brew)
$(BREW): URL=https://raw.githubusercontent.com/Homebrew/install/master/install
$(BREW): ; ruby -e "$$(curl -fsSL $(URL))"

dep:
ifeq ($(SYSTEM),Darwin)
dep: $(DARWIN_REBUILD) $(BREW)
endif
	echo "trusted-users = root $(USER)" | sudo tee -a /etc/nix/nix.conf
	echo "experimental-features = nix-command" | sudo tee -a /etc/nix/nix.conf
ifeq ($(SYSTEM),Darwin)
	sudo rm -rf /etc/shells /etc/zprofile /etc/zshrc
	sudo launchctl stop org.nixos.nix-daemon
	sudo launchctl start org.nixos.nix-daemon
endif
ifeq ($(SYSTEM),Linux)
	sudo pkill nix-daemon
endif
.PHONY: dep

# Nix specialisation.
FLAGS   		+=-I "config=$(WORKDIR)/config"
FLAGS 			+=-I "modules=$(WORKDIR)/modules"
FLAGS			+=-I "bin=$(WORKDIR)/bin"
ifdef DEBUG
FLAGS			+=--verbose
FLAGS			+=--show-trace
endif
ifeq ($(SYSTEM),Linux)
NIXOS_PREFIX  	:=$(PREFIX)/etc/nixos
NIXOS_INSTALL	:=nixos-install --root "$(PREFIX)" $(FLAGS)

NIX_REBUILD		:=sudo -E nixos-rebuild $(FLAGS)
endif
ifeq ($(SYSTEM),Darwin)
FLAGS			+=-I darwin-config=$(WORKDIR)/machines/$(HOSTNAME)/default.nix
NIX_REBUILD		:=$(DARWIN_REBUILD) $(FLAGS)
endif
NIX_BUILD 		:=nix-build $(FLAGS)

# Nix channels.
CH_NIXOS 			?="https://nixos.org/channels"
CH_NIXOS_STABLE 	?="$(CH_NIXOS)/nixos-20.03"
CH_NIXOS_UNSTABLE 	?="$(CH_NIXOS)/nixos-unstable"
CH_NIXOS_HARDWARE 	?="https://github.com/NixOS/nixos-hardware/archive"
CH_NIX_DARWIN 	 	?="https://github.com/LnL7/nix-darwin/archive"
CH_HOME_MANAGER 	?="https://github.com/rycee/home-manager/archive"

channels:
ifeq ($(SYSTEM),Darwin)
	nix-channel --add "$(CH_NIXOS_UNSTABLE)" nixpkgs
	nix-channel --add "$(CH_NIX_DARWIN)/master.tar.gz" darwin
endif
ifeq ($(SYSTEM),Linux)
	nix-channel --add "$(CH_NIXOS_UNSTABLE)" nixos
	nix-channel --add "$(CH_NIXOS_HARDWARE)/master.tar.gz" nixos-hardware
endif
	nix-channel --add "$(CH_HOME_MANAGER)/master.tar.gz" home-manager
	nix-channel --add "$(CH_NIXOS_STABLE)" nixpkgs-stable
.PHONY: channels

update:
ifeq ($(SYSTEM),Darwin)
	$(BREW) update --quiet
endif
	sudo nix-channel --update
	nix-channel --update
.PHONY: update

# Configuration.
$(NIXOS_PREFIX)/configuration.nix:
	sudo nixos-generate-config --root "$(PREFIX)"
	echo "import $(WORKDIR)/machines/$(HOSTNAME)" | \
		sudo tee "$(NIXOS_PREFIX)/configuration.nix" >/dev/null

$(XDG_CONFIG_HOME)/emacs:
	git clone https://github.com/hlissner/doom-emacs $@
# Sadly not everything in the Emacs world is supporting XDG yet.
	ln -sf $@ $(HOME)/.emacs.d
$(XDG_CONFIG_HOME)/doom: ; ln -sf $(WORKDIR)/config/emacs $@

config: $(NIXOS_PREFIX)/configuration.nix
config-emacs: $(XDG_CONFIG_HOME)/doom $(XDG_CONFIG_HOME)/emacs ; doom install
.PHONY: config config-emacs

# Runtime targets.
gc:
ifeq ($(SYSTEM),Darwin)
	$(BREW) bundle cleanup --zap -f
endif
	nix-collect-garbage -d
	sudo nix-collect-garbage -d
.PHONY:	gc

test: ACTION=$(if $(filter-out Linux,$(SYSTEM)),check,test)
test: ; $(NIX_REBUILD) $(ACTION)
.PHONY: test

switch: 	; $(NIX_REBUILD) switch
rollback: 	; $(NIX_REBUILD) switch --rollback
upgrade: 	; $(NIX_REBUILD) switch --upgrade
boot: 		; $(NIX_REBUILD) boot
dry: 		; $(NIX_REBUILD) dry-build
.PHONY:		switch rollback boot dry

install: channels update config ; $(NIXOS_INSTALL)
.PHONY: install

# CI targets.
# $(GITHUB_ACTIONS) == true
# $(TRAVIS) == true
ci: dep channels update
ifeq ($(SYSTEM),Linux)
	NIX_PATH=$(HOME)/.nix-defexpr/channels$${NIX_PATH:+:}$(NIX_PATH) \
	&& $(NIX_BUILD) '<nixpkgs/nixos>' -A vm -k \
		-I nixos-config=$(WORKDIR)/machines/ci/vm.nix
else
	if test -e /etc/static/bashrc; then . /etc/static/bashrc; fi \
	&& $(MAKE) test HOSTNAME=ci
endif
.PHONY: ci

# Theme targets.
$(WORKDIR)/theme.nix:
ifndef NIX_THEME
	$(error ERROR: NIX_THEME missing)
endif
	echo "<modules/themes/$(NIX_THEME)>" > $@

nix-switch-theme: $(WORKDIR)/theme.nix switch
.PHONY: nix-switch-theme

# Below are the leftover imperative commands needed after a Nix theme switch.

# It is surprisingly difficult to programmatically change a macOS background
# across all spaces!
darwin-wallpaper: WALLPAPER ?=$(XDG_CONFIG_HOME)/wallpaper
darwin-wallpaper:
	osascript \
		-e 'tell application "System Events"' \
		-e 'set picture of every desktop to POSIX file "'$(WALLPAPER)'"' \
		-e 'end tell' &
	sqlite3  ~/Library/Application\ Support/Dock/desktoppicture.db \
		"update data set value = '$(WALLPAPER)'"
	killall Dock
.PHONY: darwin-wallpaper

light: EMACS_THEME ?=doom-solarized-light
light: TERM_THEME ?=base16-solarized-light.sh
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
endif
	echo "(setq doom-theme '$(EMACS_THEME))" >$(XDG_CONFIG_HOME)/doom/+theme.el
	emacsclient -a "" -n -e "(setq doom-theme '$(EMACS_THEME))" \
		-e "(doom/reload-theme)" &>/dev/null
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
	ln -sf $(ZGEN_DIR)/chriskempson/base16-shell-master/scripts/$(TERM_THEME) \
		$(ZDOTDIR)/theme.zsh
endif
	echo "(setq doom-theme '$(EMACS_THEME))" >$(XDG_CONFIG_HOME)/doom/+theme.el
	emacsclient -a "" -n -e "(setq doom-theme '$(EMACS_THEME))" \
		-e "(doom/reload-theme)" &>/dev/null
.PHONY: dark

# Make defaults.
all: switch
clean: ; rm -f result
.PHONY: all clean
