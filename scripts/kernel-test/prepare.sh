#!/bin/sh -ex
KERNEL_BUILD="${KERNEL_BUILD:-0}"

/kernel-test/initrd-build.sh

if [ "$KERNEL_BUILD" = 1 ]; then
	/kernel-test/kernel-build.sh
else
	cp /boot/vmlinuz-* /cache/kernel-test/linux
fi
