#!/bin/sh -ex
KERNEL_BUILD="${KERNEL_BUILD:-0}"

# Test if the kernel boots up, and initd code runs through without error
kernel_smoke_test() {
	local log=/cache/kernel-test/smoke_test.log
	/kernel-test/run-qemu.sh SMOKE_TEST > "$log" 2>&1 || true
	if ! grep -q SMOKE_TEST_SUCCESS "$log"; then
		cat "$log"
		echo "ERROR: failed to boot the kernel and initrd in QEMU!"
		exit 1
	fi
}

/kernel-test/initrd-build.sh

if [ "$KERNEL_BUILD" = 1 ]; then
	/kernel-test/kernel-build.sh
else
	cp /boot/vmlinuz-* /cache/kernel-test/linux
fi

kernel_smoke_test
