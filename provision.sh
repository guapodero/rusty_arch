# Initially intended for Vagrant/VirtualBox.
# https://wiki.archlinux.org/title/VirtualBox/Install_Arch_Linux_as_a_guest
# https://gitlab.archlinux.org/archlinux/arch-boxes/-/blob/master/images/vagrant-virtualbox.sh.

# pacman
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
hwclock --systohc
pacman-key --init
pacman-key --populate
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm --ignore linux

# LTS kernel
# http://www.michaelghens.com/posts/2019/setting-up-arch-linux-in-virtural-box/
pacman -S --noconfirm linux-lts
sed -i -E "s/^#?GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i -E "s/^#?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i -E "s/^#?GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sed -i -E "s/^#?IgnorePkg.*=.*/IgnorePkg = linux/" /etc/pacman.conf # don't upgrade default kernel anymore

# revert vbox guest additions to 6.1 to match host
pacman -U --noconfirm --disable-download-timeout https://archive.archlinux.org/packages/v/virtualbox-guest-utils-nox/virtualbox-guest-utils-nox-6.1.40-1-x86_64.pkg.tar.zst
sed -i -E "s/^#?IgnorePkg.*=.*/& virtualbox-guest-utils-nox-*/" /etc/pacman.conf

# shell
pacman -S --noconfirm zsh git starship lsd # ohmyzsh installer depends on git
sudo -k chsh -s /usr/bin/zsh vagrant
sudo -u vagrant sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cat <<eos >> /home/vagrant/.zshrc

# shell
eval "$(starship init zsh)"
alias ls='lsd'
eos

# dev
pacman -S --noconfirm rustup rust-analyzer gcc helix zellij
sudo -u vagrant rustup default stable
sudo -u vagrant rustup install nightly
cat <<eos >> /home/vagrant/.zshrc

# dev
alias hx='helix'
alias ze='zellij'
ZELLIJ_AUTO_ATTACH=true
eval '$(zellij setup --generate-auto-start zsh)'
path+=("/home/vagrant/.cargo/bin")
export PATH
eos
