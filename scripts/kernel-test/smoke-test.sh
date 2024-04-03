#!/bin/sh -ex
# Test if the kernel boots up, and initd code runs through without error

LOG=/tmp/smoke_test.log

/kernel-test/run-qemu.sh SMOKE_TEST > "$LOG" 2>&1 || true

if ! grep -q SMOKE_TEST_SUCCESS "$LOG"; then
	cat "$LOG"
	set +x
	echo "ERROR: failed to boot the kernel and initrd in QEMU!"
	exit 1
fi
