#!/bin/bash

set -e

NETDEV="$1"
CONTAINER="$2"

die () {
  status="$1"
  shift
  warn "$@"
  exit "$status"
}

DOCKER_PID=$(docker inspect --format='{{ .State.Pid }}' $2)

[ ! -d /var/run/netns ] && mkdir -p /var/run/netns
rm -f "/var/run/netns/$DOCKER_PID"
ln -s "/proc/$DOCKER_PID/ns/net" "/var/run/netns/$DOCKER_PID"

[ "$DOCKERPID" = 0 ] && {
        die 1 "Docker inspect returned invalid PID 0"
}

[ "$DOCKERPID" = "<no value>" ] && {
        die 1 "Container $GUESTNAME not found, and unknown to Docker."
}

ip link set "$NETDEV" netns "$DOCKER_PID"
ip netns exec "$DOCKER_PID" sethdlc "$NETDEV" fr lmi none
ip netns exec "$DOCKER_PID" ip link set "$NETDEV" up

rm -f "/var/run/netns/$DOCKER_PID"
