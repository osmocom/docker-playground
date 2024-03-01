#!/bin/sh -ex

# Add one or more files to the initramfs, with parent directories.
# usr-merge: resolve symlinks for /lib -> /usr/lib etc. so "cp --parents" does
# not fail with "cp: cannot make directory '/tmp/initrd/lib': File exists"
# $@: path to files
initrd_add_file() {
	local i

	for i in "$@"; do
		case "$i" in
		/bin/*|/sbin/*|/lib/*|/lib64/*)
			cp -a --parents "$i" /tmp/initrd/usr
			;;
		*)
			cp -a --parents "$i" /tmp/initrd
			;;
		esac
	done
}

# Add kernel module files with dependencies
# $@: kernel module names
initrd_add_mod() {
	if [ "$KERNEL_BUILD" = 1 ]; then
		# Custom kernel will be built, don't add any modules from the
		# distribution's kernel to the initramfs.
		return
	fi

	local kernel="$(basename /lib/modules/*)"
	local files="$(modprobe \
		-a \
		--dry-run \
		--show-depends \
		--set-version="$kernel" \
		"$@" \
		| sort -u \
		| cut -d ' ' -f 2)"

	initrd_add_file $files

	# Save the list of modules, so initrd-init.sh can load all of them
	for i in $@; do
		echo "$i" >> /tmp/initrd/modules
	done
}

# Add binaries with depending libraries
# $@: paths to binaries
initrd_add_bin() {
	local bin
	local bin_path
	local file

	for bin in "$@"; do
		local bin_path="$(which "$bin")"
		if [ -z "$bin_path" ]; then
			echo "ERROR: file not found: $bin"
			exit 1
		fi

		lddtree_out="$(lddtree -l "$bin_path")"
		if [ -z "$lddtree_out" ]; then
			echo "ERROR: lddtree failed on '$bin_path'"
			exit 1
		fi

		for file in $lddtree_out; do
			initrd_add_file "$file"

			# Copy resolved symlink
			if [ -L "$file" ]; then
				initrd_add_file "$(realpath "$file")"
			fi
		done
	done
}

# Add command to run inside the initramfs
# $@: commands
initrd_add_cmd() {
	local i

	if ! [ -e /tmp/initrd/cmd.sh ]; then
		echo "#!/bin/sh -ex" > /tmp/initrd/cmd.sh
		chmod +x /tmp/initrd/cmd.sh
	fi

	for i in "$@"; do
		echo "$i" >> /tmp/initrd/cmd.sh
	done
}

mkdir -p /tmp/initrd
cd /tmp/initrd

for dir in bin sbin lib lib64; do
	ln -s usr/"$dir" "$dir"
done

mkdir -p \
	dev/net \
	proc \
	sys \
	tmp \
	usr/bin \
	usr/sbin

initrd_add_bin \
	busybox

initrd_add_mod \
	virtio_net \
	virtio_pci

initrd_add_file \
	/lib/modules/*/modules.dep

mknod dev/null c 1 3

# Required for osmo-ggsn
mknod dev/net/tun c 10 200

cp /kernel-test/initrd-init.sh init

# Add project specific files (e.g. osmo-ggsn and gtp kernel module)
. /cache/kernel-test/initrd-project-script.sh

find . -print0 \
	| cpio --quiet -o -0 -H newc \
	| gzip -1 > /cache/kernel-test/initrd
