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
NIX_REBUILD 	:=sudo nixos-rebuild $(FLAGS)
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

################################################################################
# Parasite VM for macOS.
#
# Initial bootstrap notes:
# 1. Mount a NixOS minimal ISO to a VMWare VM
# 2. Notable configs:
# - Keyboard: disable all apart from command-ctrl.
# - Display: 3d Acceleration, full shared graphics memory and use Retina
# - Hard-disk: NVMe and allocate full disk upfront
# - Delete soundcard
# - Isolation: remove drag and drop
# - USB: Enable controller; passthrough Yubi
#   https://support.yubico.com/hc/en-us/articles/360013647640
# - Advanced: Disable side channel mitigations
#   https://kb.vmware.com/s/article/79832
# - Advanced: Harddisk buffering
# - Advanced: Passthru power
# 3. Boot the VM, `sudo su` and change the password to 'root'
# 4. Grab the addreess from `ip addr` and run the target
# 5. Copy keys over sneakernet.
#    ssh mbaillie@172.16.136.128 mkdir -p /home/mbaillie/.local/share
#    scp $XDG_DATA_HOME/keys.txt \
#    mbaillie@172.16.136.128:/home/mbaillie/.local/share/keys.txt
# 6. Switch to the parasite configuration.
#    ssh mbaillie@172.16.136.128
#    cd /etc/dotfiles && make switch
parasite: PARASITE_ADDR ?=172.16.136.128
parasite: SSH_OPTIONS   =-o PubkeyAuthentication=no
parasite: SSH_OPTIONS   +=-o UserKnownHostsFile=/dev/null
parasite: SSH_OPTIONS   +=-o StrictHostKeyChecking=no
parasite: ; ssh $(SSH_OPTIONS) root@$(PARASITE_ADDR) " \
		parted /dev/nvme0n1 -- mklabel gpt; \
		parted /dev/nvme0n1 -- mkpart primary 512MiB -8GiB; \
		parted /dev/nvme0n1 -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/nvme0n1 -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/nvme0n1p1; \
		mkswap -L swap /dev/nvme0n1p2; \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		swapon /dev/disk/by-label/swap; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
            environment.systemPackages = with pkgs; [ gitMinimal gnumake vim ];\n \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			nix.settings.substituters = [\"https://martinbaillie.cachix.org\"];\n \
			nix.settings.trusted-public-keys = [\"martinbaillie.cachix.org-1:clUspg2ke4PWimP2gYEtm1/lvbcDDEc8yFP6lgOiqlQ=\"];\n \
            networking.hostName = \"parasite\";\n \
			services.openssh.enable = true;\n \
			services.openssh.passwordAuthentication = true;\n \
			services.openssh.permitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
			users.users.mbaillie.uid = 501;\n \
			users.users.mbaillie.initialPassword = \"mbaillie\";\n \
			users.users.mbaillie.group = \"users\";\n \
			users.users.mbaillie.extraGroups = [ \"wheel\" ];\n \
			users.users.mbaillie.isNormalUser = true;\n \
			fileSystems.\"/etc/dotfiles\".device = \".host:/dotfiles\";\n \
			fileSystems.\"/etc/dotfiles\".fsType = \"fuse./run/current-system/sw/bin/vmhgfs-fuse\";\n \
			fileSystems.\"/etc/dotfiles\".options = [ \"nofail,allow_other,uid=501,gid=100\" ];\n \
			virtualisation.vmware.guest.enable = true;\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
		reboot; \
	"
