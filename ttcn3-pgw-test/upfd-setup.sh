#!/bin/sh

create_tun() {
    name="$1"
    if ! grep "$name" /proc/net/dev > /dev/null; then
        ip tuntap add name $name mode tun
    fi
}

add_addr() {
    name="$1"
    addr="$2"
    ip addr del "$addr" dev "$name" 2> /dev/null
    ip addr add "$addr" dev "$name"
}

create_tun "ogstun4"
create_tun "ogstun6"
create_tun "ogstun46"

add_addr "ogstun46" "10.45.0.1/16"
add_addr "ogstun46" "cafe::1/64"

ip link set ogstun4 up
ip link set ogstun6 up
ip link set ogstun46 up
