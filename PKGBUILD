# Butchering a PKGBUILD to manage my Arch Linux dependencies

pkgname=arch-linux-deps
pkgver=1.0
pkgrel=1
pkgdesc="Personal PGKBUILD that installs my Arch Linux dependencies"
url="https://github.com/martinbaillie/dotfiles.git"
arch=('x86_64' 'i686')
makedepends=(
# fundamentals
'vim'
'zsh'
'tmux'
'git'

# xorg
'xorg-server'
'xorg-xinit'
'xorg-xset'
'xorg-xrdb'
'xorg-xrandr'
'xorg-xsetroot'
'xorg-setxkbmap'
'xorg-xwininfo'
'xorg-xprop'
'xorg-xfd'
'xorg-xlsfonts'
'xorg-xmodmap'
'xorg-xmessage'
'xclip'
'xdotool'
'gtk3'
'gnome-themes-standard'
'slim'
'xautolock'

# misc desktop
'conky'
'polkit'
'rng-tools'
'ntp'
'autofs'
'cronie'
'pm-utils'
'ntfs-3g'
'unclutter'
'mpd'
'mpc'
'ncmpcpp'
'alsa-utils'
'podget'
'redshift'
'wmname'
'compton'
'dunst'
'scrot'
'pcmanfm'
'evince'
'irssi'
'urxvtcd'
'urxvt-perls'
'openssh'
'wget'
'unzip'

# browser
'firefox'
'chromium'
'chromium-pepper-flash'

# laptop
'acpi'
'acpid'
'xf86-input-synaptics'
'xorg-xinput'
'xorg-xbacklight'
'ncdu'

# work
'vagrant'
'virtualbox'
'ruby'
'dnsutils'
'nmap'
'htop'
'lsof'
'ltrace'
'strace'
)
aurdepends=(
# xorg
'xmonad-git'
'xmonad-contrib-git'

# misc desktop
'siji-git'
'gohufont'
'phallus-fonts-git'
'bdf-tewi-git'
'powerline-fonts-git'
'ttf-dejavu'
'ttf-liberation'
'adobe-source-han-sans-otc-fonts'
'archlinux-themes-slim'
'lemonbar-xft-git'
'dmenu-xft-mouse-height-fuzzy-history'
'hsetroot'
'rxvt-unicode-256xresources'
'sift-bin'
'st'
'transmission-gtk'
'transmission-remote-gtk'
'the_silver_searcher'
'speedtest-cli'
'archey-git'
'nixnote2-git'

# package building
'pkgbuild-introspection'
'namcap'

# laptop
'wireless_tools'

# work
'icaclient'
'slack-desktop'
'jdk7'
'docker-git'
'docker-compose-git'
#'chef-dk'
)
license="BSD"
install="${pkgname}.install"

prepare() {
# Install yaourt if not available
if ! type yaourt &> /dev/null; then
    echo "Missing AUR helper: yaourt. Installing now"
    curl https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz | tar xz -C /tmp
    curl https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz | tar xz -C /tmp
    pushd /tmp/package-query && makepkg --needed -c --noconfirm -i package-query && popd
    pushd /tmp/yaourt && makepkg --needed -c --noconfirm -i yaourt && popd
    rm -rf /tmp/yaourt /tmp/package-query
fi
    echo "Installing AUR dependencies using helper: yaourt"
    yaourt -S --noconfirm --needed ${aurdepends[@]}
}

build() { :; }
package() { :; }
