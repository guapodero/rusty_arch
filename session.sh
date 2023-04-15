#!/bin/sh

if [ "$(vagrant status --machine-readable | grep state-human-short | cut -d , -f 4)" != running ]; then
    vagrant up
fi

trap 'kill 0' EXIT # https://stackoverflow.com/a/66537957
./tunnel.sh 5000 &
vagrant ssh
