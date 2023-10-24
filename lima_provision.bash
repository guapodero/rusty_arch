set -eux -o pipefail
echo "HOST_TZ: $HOST_TZ"
echo "HOST_WORKDIR: $HOST_WORKDIR"
echo "USERNAME: $USERNAME"
echo "HOME_DIR: $HOME_DIR"

# environment vars
echo "HOST_WORKDIR=$HOST_WORKDIR" >> /etc/environment
echo "XDG_CONFIG_HOME=\${HOME}/.config" >> $HOME_DIR/.zshenv

hostnamectl set-hostname "${HOSTNAME#"lima-"}"

# pacman
ln -sf /usr/share/zoneinfo/$HOST_TZ /etc/localtime
hwclock --hctosys --utc
pacman-key --init
pacman-key --populate
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm --ignore linux

# LTS kernel
pacman -S --noconfirm linux-lts
sed -i -E "s/^#?GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i -E "s/^#?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i -E "s/^#?GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sed -i -E "/#IgnorePkg/a IgnorePkg = linux" /etc/pacman.conf  # don't upgrade default kernel anymore

# shell
pacman -S --noconfirm git zsh starship lsd ripgrep bat
sudo -k chsh -s /usr/bin/zsh $USERNAME
sudo -u $USERNAME sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended # depends on git
cat <<'eos' >> $HOME_DIR/.zshrc

eval "$(starship init zsh)"
alias ls='lsd'
eos

# dev
pacman -S --noconfirm rustup rust-analyzer clang helix zellij cargo-make podman
sudo -u $USERNAME rustup default stable
sudo -u $USERNAME cargo install cross --git https://github.com/cross-rs/cross # depends on podman
cat <<'eos' >> $HOME_DIR/.zshrc

ZELLIJ_AUTO_ATTACH=true
eval "$(zellij setup --generate-auto-start zsh)"
path+=("$HOME/.cargo/bin")
export PATH

[ -e $XDG_CONFIG_HOME/zsh/my_profile.zsh ] && source $XDG_CONFIG_HOME/zsh/my_profile.zsh
eos

# paru AUR helper (depends on cargo)
pacman -S --noconfirm base-devel
su $USERNAME <<'eos'
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
eos

sudo -u $USERNAME paru -S --noconfirm --skipreview riffdiff

# serve local documentation
DOCS_DIR=$(sudo -u $USERNAME rustup doc --path | xargs dirname)
cat <<eos > $HOME_DIR/serve_docs.sh
#!/bin/sh
(ss -tnlp | tr -s ' ' | cut -d ' ' -f 4 | grep "*:9306") || (
  podman run -d -v $DOCS_DIR:/web -p 9306:8080 docker.io/halverneus/static-file-server:latest
)
echo "http://localhost:9306"
eos
chmod 755 $HOME_DIR/serve_docs.sh

chown -R $USERNAME:$USERNAME $HOME_DIR
