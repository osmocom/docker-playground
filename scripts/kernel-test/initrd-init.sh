#!/bin/busybox sh
echo "Running initrd-init.sh"
set -ex

export HOME=/root
export LD_LIBRARY_PATH=/usr/local/lib
export PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/local/sbin:/usr/sbin
export TERM=screen

/bin/busybox --install -s

hostname qemu

mount -t proc proc /proc
mount -t sysfs sys /sys

# Load modules from initrd-build.sh:initrd_add_mod()
if [ -e /modules ]; then
	cat /modules | xargs -t -n1 modprobe
fi

ip link set lo up
ip link set eth0 up

if grep -q SMOKE_TEST /proc/cmdline; then
	# Called from scripts/kernel-test/prepare.sh:kernel_smoke_test() to
	# verify that the kernel + initramfs boot up properly. Output this
	# string instead of running the actual commands.
	echo "SMOKE_TEST_SUCCESS"
else
	# Run project specific commands, added with initrd_add_cmd (see
	# inird-ggsn.sh for example). Use '|| true' to avoid "attempting to
	# kill init" kernel panic on failure.
	/cmd.sh || true
fi

# Avoid kernel panic when init exits
poweroff -f
