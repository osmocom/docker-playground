#!/bin/sh
# Sourced by scripts/kernel-test/initrd-build.sh

initrd_add_mod \
	gtp \
	tun

initrd_add_bin \
	osmo-ggsn

initrd_add_file \
	/data/osmo-ggsn.cfg

# Enable dynamic_debug, if it is compiled into the kernel
initrd_add_cmd \
	"mount -t debugfs none /sys/kernel/debug || true" \
	"(cat /sys/kernel/debug/dynamic_debug/control | grep gtp) || true" \
	"echo -n 'module gtp +p' > /sys/kernel/debug/dynamic_debug/control || true"

initrd_add_cmd \
	"ip addr add 172.18.3.201/24 brd 172.18.3.255 dev eth0" \
	"ip route add default via 172.18.3.1 dev eth0" \
	"osmo-ggsn -c /data/osmo-ggsn.cfg"
