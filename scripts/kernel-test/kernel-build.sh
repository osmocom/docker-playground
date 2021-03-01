#!/bin/sh -ex
# Environment variables are described in README.md

KERNEL_REMOTE_NAME="${KERNEL_REMOTE_NAME:-net-next}"
KERNEL_URL="${KERNEL_URL:-https://git.kernel.org/pub/scm/linux/kernel/git/netdev/net-next.git}"
KERNEL_BRANCH="${KERNEL_BRANCH:-master}"
KERNEL_DIR=/cache/linux


# Add the kernel repository as git remote, fetch it, checkout the given branch
prepare_git_repo() {
	local url

	if ! [ -d "$KERNEL_DIR" ]; then
		mkdir -p "$KERNEL_DIR"
		git -C "$KERNEL_DIR" init
	fi

	cd "$KERNEL_DIR"

	if ! git remote | grep -q "^$KERNEL_REMOTE_NAME$"; then
		git remote add "$KERNEL_REMOTE_NAME" "$KERNEL_URL"
	else
		url="$(git remote get-url "$KERNEL_REMOTE_NAME")"
		if [ "$url" != "$KERNEL_URL" ]; then
			set +x
			echo "ERROR: the checked out repository already has" \
				"a remote with the same name, pointing to a" \
				"different URL!"
			echo
			echo "KERNEL_REMOTE_NAME:       $KERNEL_REMOTE_NAME"
			echo "KERNEL_URL (parameter):   $KERNEL_URL"
			echo "KERNEL_URL (checked out): $url"
			echo
			echo "Please restart the job, and either change the" \
				"KERNEL_URL parameter to the same value, or" \
				"use a different KERNEL_REMOTE_NAME."
			exit 1
		fi
	fi

	git fetch "$KERNEL_REMOTE_NAME"
	git checkout "$KERNEL_REMOTE_NAME/$KERNEL_BRANCH"
}

update_kernel_config() {
	local previous="/cache/kernel-test/previous.config"
	local fragment="/cache/kernel-test/fragment.config"

	cd "$KERNEL_DIR"
	make "$KERNEL_CONFIG_BASE"
	scripts/kconfig/merge_config.sh -m .config "$fragment"
	make olddefconfig

	if [ -e "$previous" ] && ! diff -q "$previous" .config; then
		# Remove everything built with previous config
		echo "Kernel config changed, running 'make clean'"
		make clean
	fi

	cp .config "$previous"
}

prepare_git_repo
update_kernel_config

make "-j$(nproc)"
cp arch/x86/boot/bzImage /cache/kernel-test/linux
