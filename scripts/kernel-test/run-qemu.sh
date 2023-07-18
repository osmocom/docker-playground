#!/bin/sh -ex
# Arguments are appended to the kernel cmdline

random_mac() {
	printf "52:54:"
	date "+%c %N" | sha1sum | sed 's/\(.\{2\}\)/\1:/g' | cut -d: -f 1-4
}

KERNEL_CMDLINE="
	root=/dev/ram0
	console=ttyS0
	panic=-1
	init=/init
	$@
"

if [ -e /dev/kvm ]; then
	MACHINE_ARG="-machine pc,accel=kvm"
else
	MACHINE_ARG="-machine pc"
fi

qemu-system-x86_64 \
	$MACHINE_ARG \
	-smp 1 \
	-m 512M \
	-no-user-config -nodefaults -display none \
	-gdb unix:/cache/kernel-test/gdb.pipe,server=on,wait=off \
	-no-reboot \
	-kernel /cache/kernel-test/linux \
	-initrd /cache/kernel-test/initrd \
	-append "${KERNEL_CMDLINE}" \
	-serial stdio \
	-chardev socket,id=charserial1,path=/cache/kernel-test/gdb-serial.pipe,server=on,wait=off \
	-device isa-serial,chardev=charserial1,id=serial1 \
	-netdev tap,id=nettest,script=/kernel-test/qemu-ifup.sh,downscript=/kernel-test/qemu-ifdown.sh \
	-device virtio-net-pci,netdev=nettest,mac="$(random_mac)"
