#!/bin/sh
docker run --cap-add=NET_ADMIN --device /dev/net/tun:/dev/net/tun --network sigtran --ip 172.18.0.201 -it osmo-ggsn-master
