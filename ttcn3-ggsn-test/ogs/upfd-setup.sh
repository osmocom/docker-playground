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

add_addr "ogstun4" "176.16.222.1/16"
add_addr "ogstun6" "2001:780:44:2000:0:0:0:1/64"
add_addr "ogstun46" "176.16.46.1/24"
add_addr "ogstun46" "2001:780:44:2100:0:0:0:1/64"

ip link set ogstun4 up
ip link set ogstun6 up
ip link set ogstun46 up
