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

# shell
pacman -S --noconfirm git zsh starship lsd ripgrep bat skim # start_zellij.zsh depends on skim
sudo -k chsh -s /usr/bin/zsh $USERNAME
sudo -u $USERNAME \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" \
    --unattended # depends on git
cat <<'eos' >> $HOME_DIR/.zshrc
eval "$(starship init zsh)"
alias ls='lsd'
eos

# dev
pacman -S --noconfirm base-devel rustup rust-analyzer clang helix zellij cargo-make podman httplz
sudo -u $USERNAME rustup default stable
curl -L --proto '=https' --tlsv1.2 -sSf \
    https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
sudo -u $USERNAME cargo binstall --no-confirm --no-discover-github-token cross
cat <<'eos' >> $HOME_DIR/.zshrc
path+=("$HOME/.cargo/bin")
export PATH
alias hx='helix'
alias shx='sudo /usr/bin/helix -c $XDG_CONFIG_HOME/helix/config.toml'
eos

#
# USER SPACE
#
chown -R $USERNAME:$USERNAME $HOME_DIR
su $USERNAME

# start zellij once on login
cat <<'eos' >> $HOME/.zprofile
ZELLIJ_AUTO_ATTACH=true
ZELLIJ_AUTO_EXIT=true
source $XDG_CONFIG_HOME/zsh/start_zellij.zsh
eos

# paru AUR helper (depends on base-devel and cargo)
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm

paru -S --noconfirm --skipreview riffdiff

cat <<'eos' > $HOME/serve_docs.sh
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
chmod 755 $HOME/bin/serve_docs.sh
