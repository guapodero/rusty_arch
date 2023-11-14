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
sed -i "s/#Color/Color/" /etc/pacman.conf

# LTS kernel
pacman -S --noconfirm linux-lts
sed -i -E "s/^#?GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
sed -i -E "s/^#?GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=true/" /etc/default/grub
sed -i -E "s/^#?GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sed -i -E "/#IgnorePkg/a IgnorePkg = linux" /etc/pacman.conf  # don't upgrade default kernel anymore

pacman -S --noconfirm \
    git zsh starship \
    base-devel rustup rust-analyzer clang \
    zellij lsd ripgrep bat skim helix \
    cargo-make podman cross cargo-binstall httplz

sudo -k chsh -s /usr/bin/zsh $USERNAME

sudo -u $USERNAME \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" \
    --unattended

sudo -u $USERNAME cat <<'eos' >> $HOME/.zshrc
eval "$(starship init zsh)"
alias ls='lsd'
alias hx='helix'
alias shx='sudo /usr/bin/helix -c $XDG_CONFIG_HOME/helix/config.toml'
alias dhx="helix -c <(sed '/\[editor.lsp\]/a enable=false' $XDG_CONFIG_HOME/helix/config.toml)"
path+=("$HOME/.cargo/bin")
export PATH
eos

# start_zellij.zsh (depends on skim)
sudo -u $USERNAME cat <<'eos' >> $HOME/.zprofile
ZELLIJ_AUTO_ATTACH=true
ZELLIJ_AUTO_EXIT=true
source $XDG_CONFIG_HOME/zsh/start_zellij.zsh
eos

sudo -u $USERNAME rustup default stable

# paru AUR helper (depends on base-devel and cargo)
su $USERNAME <<'eos'
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
eos

sudo -u $USERNAME paru -S --noconfirm --skipreview riffdiff

# rust books and documentation
sudo -u $USERNAME cat <<'eos' > $HOME/serve_docs.sh
#!/bin/sh

PID="$(ss -tnlp | tr -s ' ' | cut -d ' ' -f 1,4,6 \
    | grep 'LISTEN 0.0.0.0:9306' | grep -Po 'pid=\d+' | cut -d = -f 2)"

if [[ -z "$PID" ]]; then
    echo "http://localhost:9306"
    httplz -p 9306 $(rustup doc --path | xargs dirname) > /dev/null &
else
    echo $PID
fi
eos
chmod 755 $HOME/serve_docs.sh
