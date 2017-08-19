#!/bin/sh
docker volume rm ggsn-vol
docker run --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun --rm --network sigtran --ip 172.18.0.201 -v ggsn-vol:/data -it osmo-ggsn-master
