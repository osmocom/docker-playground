#!/bin/sh

if ! grep "ogstun" /proc/net/dev > /dev/null; then
    ip tuntap add name ogstun mode tun
fi
ip addr del 176.16.222.1/16 dev ogstun 2> /dev/null
ip addr add 176.16.222.1/16 dev ogstun
#ip addr del cafe::1/64 dev ogstun 2> /dev/null
#ip addr add cafe::1/64 dev ogstun
ip link set ogstun up
