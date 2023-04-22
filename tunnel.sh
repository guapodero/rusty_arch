#!/bin/sh

usage() {
    echo "Use ssh tunneling to expose a network port (ex. for a web server)"
    echo "usage: $0 port"
    exit 1
}

if [ $# -ne 1 ] || [ $1 = "-h" ]; then usage; fi

TUNNEL_PORT=$1

while ps -ef | grep "[/]usr/local/bin/vagrant" > /dev/null; do sleep 1; done

IFS=$'\n'
for l in $(vagrant ssh-config); do
    c=$(echo $l | xargs)
    k=$(echo $c | cut -d' ' -f 1)
    v=$(echo $c | cut -d' ' -f 2)
    declare $k=$v
done
unset IFS

ssh -N \
    -L ${TUNNEL_PORT}:${HostName}:${TUNNEL_PORT} \
    -p ${Port} \
    -i ${IdentityFile} \
    -o Compression=yes \
    -o IdentitiesOnly=${IdentitiesOnly} \
    -o LogLevel=${LogLevel} \
    -o StrictHostKeyChecking=${StrictHostKeyChecking} \
    -o UserKnownHostsFile=${UserKnownHostsFile} \
    ${User}@${HostName}

