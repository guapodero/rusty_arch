#!/bin/sh
set -e

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "usage: $0 [vm_name] (default: arch)" >&2
    exit 0
fi

vm_name=${1:-arch}

script_path="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"

export HOST_TZ="$(readlink /etc/localtime | sed 's#/var/db/timezone/zoneinfo/##g')"
export HOST_WORK_DIR="$(dirname ${script_path})" # this script is assumed to be in a subdirectory of workdir

qemu-system-x86_64 --version || (>&2 echo "QEMU required"; false)
limactl -h > /dev/null || (>&2 echo "lima-vm required"; false)

vm_status() {
    limactl list | tr -s ' ' | cut -d ' ' -f 1,2
}

(vm_status | grep "$vm_name" > /dev/null) || (
    echo "creating new vm $vm_name"

    limactl create \
        --name $vm_name \
        --set=".mounts[2].location |= \"$HOST_WORK_DIR\"" \
        lima_arch.yaml

    limactl start $vm_name

    limactl shell $vm_name <<eos
export HOST_TZ=$HOST_TZ
export HOST_WORK_DIR=$HOST_WORK_DIR
export USERNAME=\$(whoami)
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
    echo "starting vm $vm_name"

    limactl start $vm_name
    limactl shell $vm_name <<< "~/serve_docs.sh"
)

limactl shell $vm_name
