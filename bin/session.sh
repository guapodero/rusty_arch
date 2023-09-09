#!/bin/sh

SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [ "$(vagrant status --machine-readable | grep state-human-short | cut -d , -f 4)" != running ]; then
    vagrant up
fi

trap 'kill 0' EXIT # https://stackoverflow.com/a/66537957
${SCRIPT_PATH}/tunnel.sh 5000 &
vagrant ssh
