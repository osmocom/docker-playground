#!/bin/sh -e
br=br-test
qemu_if=$1

echo "[host] qemu-ifdown: $br and $qemu_if"
set +x

ip link set "$br" down
brctl delbr $br
