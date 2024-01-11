set -eux -o pipefail
echo "HOST_TZ: $HOST_TZ"
echo "HOST_WORKDIR: $HOST_WORKDIR"
echo "HOST_UID: $HOST_UID"
echo "HOST_GID: $HOST_GID"
echo "USERNAME: $USERNAME"
echo "HOME_DIR: $HOME_DIR"

echo "HOST_WORKDIR=$HOST_WORKDIR" >> /etc/environment
hostnamectl set-hostname "${HOSTNAME#"lima-"}"

ln -sf /usr/share/zoneinfo/$HOST_TZ /etc/localtime
hwclock --hctosys --utc
pacman-key --init
pacman-key --populate
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm
sed -i "s/#Color/Color/" /etc/pacman.conf

pacman -S --noconfirm \
    git zsh starship \
    base-devel rustup rust-analyzer clang \
    zellij lsd ripgrep bat skim helix \
    cargo-make podman cross cargo-binstall httplz

sudo -k chsh -s /usr/bin/zsh $USERNAME
usermod -u $HOST_UID $USERNAME
groupmod -g $HOST_GID $USERNAME

cat <<'eos' >> $HOME_DIR/.zshenv
XDG_CONFIG_HOME=$HOME/.config

alias ls='lsd'
alias hx='helix'
alias shx="sudo /usr/bin/helix -c $XDG_CONFIG_HOME/helix/config.toml"
alias dhx="helix -c <(sed '/\[editor.lsp\]/a enable=false' $XDG_CONFIG_HOME/helix/config.toml)"

path+=("$HOME/.cargo/bin")
eos

cat <<'eos' >> $HOME_DIR/.zshrc
eval "$(starship init zsh)"
[ -e $XDG_CONFIG_HOME/zsh/my_profile.zsh ] && source $XDG_CONFIG_HOME/zsh/my_profile.zsh
eos

cat <<'eos' >> $HOME_DIR/.zlogin
cd $HOME
ZELLIJ_AUTO_ATTACH=true
ZELLIJ_AUTO_EXIT=true
source $XDG_CONFIG_HOME/zsh/start_zellij.zsh
eos

sudo -u $USERNAME rustup default stable

su $USERNAME <<'eos'
cd /tmp
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
eos

sudo -u $USERNAME paru -S --noconfirm --skipreview riffdiff

cat <<'eos' > $HOME_DIR/serve_docs.sh
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
chmod 755 $HOME_DIR/serve_docs.sh

chown $USERNAME:$USERNAME $HOME_DIR/*
