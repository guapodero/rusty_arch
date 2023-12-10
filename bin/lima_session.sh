#!/bin/sh
set -e

if [[ $# -lt 1 || $# -gt 2 || "$1" == "-h" || "$1" == "--help" ]]; then
    echo "usage: $0 vm_name [session_name | .] # . = force new session" >&2
    exit 1
fi

qemu-system-x86_64 --version || (>&2 echo "QEMU required"; false)
limactl -h > /dev/null || (>&2 echo "lima-vm required"; false)

script_path="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

export HOST_TZ="$(readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##g')"
export HOST_WORKDIR="$(dirname ${script_path})" # this script is assumed to be in a subdirectory of workdir
export HOST_UID=$(id -u) # assumed to be running this script as a non-root user
export HOST_GID=$(id -g)

vm_name=$1
if [ $# -eq 2 ]; then
    if [[ $2 == "." ]]; then
        touch /tmp/lima/zellij_session_name
    else
        echo $2 > /tmp/lima/zellij_session_name
    fi
fi

vm_status() {
    limactl list | tr -s ' ' | cut -d ' ' -f 1,2
}

confirm() {
    read -n 1 -s -p "$1 " confirm
    [[ "$confirm" == "" || "$confirm" == [Yy]* ]] || exit 1
    echo # newline
}

curl -Is https://clients3.google.com > /dev/null || (
    confirm "lima-vm isn't functional offline. try anyway?" || exit 0
)

(vm_status | grep -E "^$vm_name \w+$" > /dev/null) || (
    confirm "create VM $vm_name?"

    limactl create \
        --name $vm_name \
        --set=".mounts[2].location |= \"$HOST_WORKDIR\"" \
        lima_arch.yaml

    limactl start $vm_name

    limactl shell $vm_name <<eos
export HOST_TZ=$HOST_TZ
export HOST_WORKDIR=$HOST_WORKDIR
export HOST_UID=$HOST_UID
export HOST_GID=$HOST_GID
export USERNAME=\$(whoami)
export HOSTNAME=\$(cat /etc/hostname)
export HOME_DIR=/home/\$USERNAME.linux # different than root $HOME
sudo -E /bin/bash lima_provision.bash
eos

    limactl copy -r dot_config/* $vm_name:~/.config/

    limactl stop $vm_name

    tag=${vm_name}.$(date +%s)
    limactl snapshot create $vm_name --tag $tag
    echo "created snapshot: $tag"
)

(vm_status | grep "$vm_name Running" > /dev/null) || (
    confirm "resume VM $vm_name?"
    limactl start $vm_name
    limactl shell --shell /bin/sh $vm_name <<< "~/serve_docs.sh > /dev/null 2>&1 < /dev/null"
)

limactl shell --debug --log-level debug $vm_name
