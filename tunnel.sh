#!/bin/sh

usage() {
  echo "Use ssh tunneling to expose a network port (ex. for a web server)"
  echo "usage: $0 port"
  exit 1
}

if [ $# -ne 1 ] || [ $1 = "-h" ]; then usage; fi

TUNNEL_PORT=$1

IFS=$'\n'
for l in $(vagrant ssh-config); do
  c=$(echo $l | xargs)
  k=$(echo $c | cut -d' ' -f 1)
  v=$(echo $c | cut -d' ' -f 2)
  declare $k=$v
done
unset IFS

echo "opening tunnel ${HostName}:${TUNNEL_PORT}"

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

