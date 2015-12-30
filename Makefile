DOTFILES 			:= $(shell pwd)
EUID					:= $(shell id -u -r)
UNAME 				:= $(shell uname -s)
GIT 					:= $(shell which git)

PRIVATE_REPO 	= $(DOTFILES)/private
LN_FLAGS 			= -sfn

ifeq ($(UNAME),Darwin)
else
endif

.PHONY: install

install: ssh zsh tmux xorg vim git bin mpd ncmpcpp irssi conky podget private

basic: ssh zsh tmux vim git

x: xorg xmonad xmobar

bin::
	@test -d ${HOME}/Code || mkdir -p ${HOME}/Code
	@ln $(LN_FLAGS) $(DOTFILES)/bin ${HOME}/Code/bin
	@echo symlinked: bin 

zsh::
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zshrc ${HOME}/.zshrc
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zshenv ${HOME}/.zshenv
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zlogin ${HOME}/.zlogin
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zfuncs ${HOME}/.zfuncs
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zprezto ${HOME}/.zprezto
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/zpreztorc ${HOME}/.zpreztorc
	@ln $(LN_FLAGS) $(DOTFILES)/zsh ${HOME}/.zsh
	@test -d ${HOME}/.config || mkdir -p ${HOME}/.config
	@ln $(LN_FLAGS) $(DOTFILES)/zsh/base16-shell ${HOME}/.config/base16-shell
	@echo symlinked: zsh

tmux::
	@ln $(LN_FLAGS) $(DOTFILES)/tmux/tmux.conf ${HOME}/.tmux.conf
	@ln $(LN_FLAGS) $(DOTFILES)/tmux ${HOME}/.tmux
	@echo symlinked: tmux

vim::
	@echo symlinked: vim
	@ln $(LN_FLAGS) $(DOTFILES)/vim/vimrc ${HOME}/.vimrc
	@ln $(LN_FLAGS) $(DOTFILES)/vim ${HOME}/.vim
	@vim +PluginInstall +qall

irssi::
	@ln $(LN_FLAGS) $(DOTFILES)/irssi ${HOME}/.irssi
	@echo symlinked: irssi

conky::
	@test -d ${HOME}/.config || mkdir -p ${HOME}/.config
	@ln $(LN_FLAGS) $(DOTFILES)/conky ${HOME}/.config/conky
	@echo symlinked: conky

git::
	@ln $(LN_FLAGS) $(DOTFILES)/git/gitconfig ${HOME}/.gitconfig
	@echo symlinked: git

xorg::
	@ln $(LN_FLAGS) $(DOTFILES)/xorg/xsession ${HOME}/.xsession
	@ln $(LN_FLAGS) $(DOTFILES)/xorg/xsession ${HOME}/.xinitrc
	@ln $(LN_FLAGS) $(DOTFILES)/xorg/Xresources ${HOME}/.Xresources
	@test -d ${HOME}/.config || mkdir -p ${HOME}/.config
	@ln $(LN_FLAGS) $(DOTFILES)/xorg/base16-xresources ${HOME}/.config/base16-xresources
	@ln $(LN_FLAGS) $(DOTFILES)/xorg/wallpapers ${HOME}/.wallpapers
	@ln $(LN_FLAGS) ${HOME}/.wallpapers/tinytile.jpg ${HOME}/.wallpapers/current
	@xrdb -load ${HOME}/.Xresources
	@echo symlinked: xorg

xmonad::
	@ln $(LN_FLAGS) $(DOTFILES)/xmonad ${HOME}/.xmonad
	@xmonad --recompile
	@echo symlinked: xmonad

xmobar::
	@test -d ${HOME}/.config || mkdir -p ${HOME}/.config
	@ln $(LN_FLAGS) $(DOTFILES)/xmobar ${HOME}/.config/xmobar
	@echo symlinked: xmobar

mpd::
	@test -d ${HOME}/.config || mkdir -p ${HOME}/.config
	@ln $(LN_FLAGS) $(DOTFILES)/mpd ${HOME}/.config/mpd
	@test -d ${HOME}/Music || mkdir -p ${HOME}/Music
	@echo symlinked: mpd

ncmpcpp::
	@ln $(LN_FLAGS) $(DOTFILES)/ncmpcpp ${HOME}/.ncmpcpp
	@echo symlinked: ncmpcpp

podget::
	@ln $(LN_FLAGS) $(DOTFILES)/podget ${HOME}/.podget
	@echo symlinked: podget 

ssh::
	@ln $(LN_FLAGS) $(DOTFILES)/ssh ${HOME}/.ssh
	@chmod 700 ${HOME}/.ssh
	@chmod 600 ${HOME}/.ssh/authorized_keys
	@echo symlinked: ssh

update:
	$(GIT) pull && $(GIT) submodule foreach git checkout master && $(GIT) submodule foreach git pull

private::
ifneq "$(wildcard $(PRIVATE_REPO) )" ""
		@ln $(LN_FLAGS) $(DOTFILES)/private/ssh/id_rsa ${HOME}/.ssh/id_rsa
		@ln $(LN_FLAGS) $(DOTFILES)/private/ssh/putty ${HOME}/.ssh/putty
		@chmod 600 ${HOME}/.ssh/id_rsa
		@ln $(LN_FLAGS) $(DOTFILES)/private/gnupg ${HOME}/.gnupg
		@ln $(LN_FLAGS) $(DOTFILES)/private/keybase ${HOME}/.keybase
		@echo symlinked: private
		@crontab ${DOTFILES}/private/etc/crontab
		@echo installed: crontab
else
		@echo private repo not found 
		@exit 1
endif

etc::
ifneq ($(EUID),0)
		@echo "Please run as root user"
		@exit 1
endif
		@ln $(LN_FLAGS) $(DOTFILES)/private/etc/slim.conf /etc/
		@ln $(LN_FLAGS) $(DOTFILES)/private/etc/slimlock.conf /etc/
		@ln $(LN_FLAGS) $(DOTFILES)/private/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist
		@ln $(LN_FLAGS) $(DOTFILES)/private/etc/ntp.conf /etc/ntp.conf
		@ln $(LN_FLAGS) $(DOTFILES)/private/etc/hosts /etc/hosts
		@echo symlinked: etc \(as root\)
	
check-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -print

clean-dead:
	find ~ -maxdepth 1 -name '.*' -type l -exec test ! -e {} \; -delete
