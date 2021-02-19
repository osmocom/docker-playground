#!/bin/sh -e
br=br-test
docker_if=eth0
qemu_if=$1

echo "[host] qemu-ifup: $br, $qemu_if, $docker_if"
set +x

ip link set "$qemu_if" up

brctl addbr "$br"
brctl addif "$br" "$qemu_if"
brctl addif "$br" "$docker_if"

ip link set "$br" up

ip a
ip route
