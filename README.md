# Dotfiles
### About
My personal configs for xmonad, lemonbar, xorg, dmenu, vim, zsh, tmux and others.

These are actively used to varying degrees on my Arch Linux, OpenBSD & OS X machines.

### Installation
- `git clone --recursive git@github.com:martinbaillie/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`
- `make dep && make install`

### Update
- `make update && make dep && make install`

### Colour Scheme
Switch between any [base16](https://github.com/chriskempson/base16) colour scheme by using `base16<tab>` at a zsh shell.
This will switch vim, zsh, Xresources, xmonad, lemonbar and dmenu to the chosen theme.

### License
[BSD License](https://en.wikipedia.org/wiki/BSD_licenses#2-clause_license_.28.22Simplified_BSD_License.22_or_.22FreeBSD_License.22.29)
