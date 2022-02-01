CACHE_DIR="$(realpath ../_cache)"
KERNEL_TEST_DIR="$(realpath ../scripts/kernel-test)"

docker_image_exists() {
	test -n "$(docker images -q "$REPO_USER/$1")"
}

docker_depends() {
	local feed

	case "$1" in
	osmo-*-20*q*-centos8)
		# e.g. osmo-mgw-2021q1-centos8 -> centos8-obs-2021q1
		feed="$(echo "$1" | grep -o -P -- "20\d\dq.*$")"  # e.g. "2021q1-centos8"
		feed="$(echo "$feed" | sed 's/\-centos8$//')" # e.g. "2021q1"
		echo "centos8-obs-$feed"
		;;
	osmo-*-latest-centos7) echo "centos7-obs-latest" ;;
	osmo-*-latest-centos8) echo "centos8-obs-latest" ;;
	osmo-*-centos7) echo "centos7-build" ;;
	osmo-*-centos8) echo "centos8-build" ;;
	osmo-*-latest) echo "debian-bullseye-obs-latest" ;;
	osmo-*) echo "debian-bullseye-build" ;;
	ttcn3-*) echo "debian-bullseye-titan" ;;
	esac
}

docker_distro_from_image_name() {
	case "$1" in
	osmo-*-centos7) echo "centos7" ;;
	osmo-*-centos8) echo "centos8" ;;
	centos7-*) echo "centos7" ;;
	centos8-*) echo "centos8" ;;
	debian-buster-*) echo "debian-buster" ;;
	*) echo "debian-bullseye" ;;
	esac
}

docker_upstream_distro_from_image_name() {
	case "$1" in
	osmo-*-centos7) echo "centos:centos7"; ;;
	osmo-*-centos8) echo "almalinux:8"; ;;
	centos7-*) echo "centos:centos7" ;;
	centos8-*) echo "almalinux:8" ;;
	debian9-*) echo "debian:stretch" ;;
	debian10-*) echo "debian:buster" ;;
	debian11-*) echo "debian:bullseye" ;;
	debian-stretch-*) echo "debian:stretch" ;;
	debian-buster-*) echo "debian:buster" ;;
	*) echo "debian:bullseye" ;;
	esac
}

docker_dir_from_image_name() {
	case "$1" in
	osmo-*-20*q*-centos8)
		# e.g. osmo-mgw-2021q1-centos8 -> osmo-mgw-latest
		echo "$1" | sed 's/20[0-9][0-9]q.*\-centos8$/latest/'
		;;
	osmo-*-centos7)
		# e.g. osmo-mgw-latest-centos7 -> osmo-mgw-latest
		echo "$1" | sed 's/\-centos7$//'
		;;
	osmo-*-centos8)
		# e.g. osmo-mgw-latest-centos8 -> osmo-mgw-latest
		echo "$1" | sed 's/\-centos8$//'
		;;
	centos8-obs-20*q*)
		# e.g. centos8-obs-2021q1 -> centos8-obs-latest
		echo "$1" | sed 's/20[0-9][0-9]q.*$/latest/'
		;;
	*)
		echo "$1"
		;;
	esac
}

# $1: distro name, from docker_distro_from_image_name()
# $2: docker image name (without $REPO_USER/ prefix)
list_osmo_packages() {
	local distro="$1"
	local image="$2"
	local docker_run_sh="docker run --rm --entrypoint=/bin/sh $REPO_USER/$image -c"

	if [ -n "$NO_LIST_OSMO_PACKAGES" ]; then
		return
	fi

	# Don't run on all images
	case "$image" in
	osmo-*) ;;
	*) return ;;
	esac

	set +x
	echo
	echo "### Installed Osmocom packages in: $image ###"
	echo

	case "$distro" in
	centos*)
		$docker_run_sh "rpm -qa | grep osmo"
		;;
	debian*)
		$docker_run_sh "dpkg -l | grep osmo"
		;;
	*)
		echo "ERROR: don't know how to list installed packages for distro=$distro"
		;;
	esac

	echo
	set -x
}

# Make sure required images are available and build them if necessary.
# $*: image names (e.g. "debian-bullseye-build", "osmo-mgw-master", "osmo-mgw-master-centos8")
#	The images are automatically built from the Dockerfile of the subdir of
#	the same name. If there is a distribution name at the end of the image
#	name (e.g. osmo-mgw-master-centos8), it gets removed from the subdir
#	where the Dockerfile is taken from (e.g. osmo-mgw-master/Dockerfile)
#	and UPSTREAM_DISTRO and DISTRO are passed accordingly (e.g.
#	UPSTREAM_DISTRO=almalinux:8 DISTRO=centos8). This allows one
#	Dockerfile for multiple distributions, without duplicating configs for
#	each distribution. Dependencies listed in docker_depends() are built
#	automatically too.
IMAGE_DIR_PREFIX=".."
docker_images_require() {
	local i
	local from_line
	local pull_arg
	local upstream_distro_arg
	local distro_arg
	local depends
	local dir

	for i in $@; do
		# Don't build images that are available on the private
		# registry, if using it. Instead, pull the images to make sure
		# they are up-to-date.
		if [ "$REGISTRY_HOST" = "registry.osmocom.org" ]; then
			case "$i" in
			debian-bullseye-titan)
				docker pull "$REGISTRY_HOST/$USER/$i"
				continue
				;;
			esac
		fi

		# Build dependencies first
		depends="$(docker_depends "$i")"
		if [ -n "$depends" ]; then
			docker_images_require $depends
		fi

		distro_arg="$(docker_distro_from_image_name "$i")"

		# Trigger image build (cache will be used when up-to-date)
		if [ -z "$NO_DOCKER_IMAGE_BUILD" ]; then
			upstream_distro_arg="$(docker_upstream_distro_from_image_name "$i")"
			dir="$(docker_dir_from_image_name "$i")"

			# Pull upstream base images
			pull_arg="--pull"
			from_line="$(grep '^FROM' ${IMAGE_DIR_PREFIX}/${dir}/Dockerfile)"
			if echo "$from_line" | grep -q '$USER'; then
				pull_arg=""
			fi

			echo "Building image: $i (export NO_DOCKER_IMAGE_BUILD=1 to prevent this)"
			make -C "${IMAGE_DIR_PREFIX}/${dir}" \
				PULL="$pull_arg" \
				UPSTREAM_DISTRO="$upstream_distro_arg" \
				DISTRO="$distro_arg" \
				IMAGE="$REPO_USER/$i" \
				|| exit 1
		fi

		# Detect missing images (build skipped)
		if ! docker_image_exists "$i"; then
			echo "ERROR: missing image: $i"
			exit 1
		fi

		list_osmo_packages "$distro_arg" "$i"
	done
}

#kills all containers attached to network
network_clean() {
	docker network inspect $NET_NAME | grep Name | cut -d : -f2 | awk -F\" 'NR>1{print $2}' | xargs -rn1 docker kill
}

network_create() {
	NET=$1
	if docker network ls | grep -q $NET_NAME; then
		echo removing stale network and containers...
		network_clean
		network_remove
	fi
	SUB4="172.18.$NET.0/24"
	SUB6="fd02:db8:$NET::/64"
	echo Creating network $NET_NAME
	docker network create --internal --subnet $SUB4 --ipv6 --subnet $SUB6 $NET_NAME
}

network_bridge_create() {
	NET=$1
	if docker network ls | grep -q $NET_NAME; then
		echo removing stale network and containers...
		network_clean
		network_remove
	fi
	SUB4="172.18.$NET.0/24"
	SUB6="fd02:db8:$NET::/64"
	echo Creating network $NET_NAME
	docker network create \
		--driver=bridge \
		--subnet $SUB4 \
		--ipv6 --subnet $SUB6 \
		-o "com.docker.network.bridge.host_binding_ipv4"="172.18.$NET.1" \
		$NET_NAME
}

network_remove() {
	echo Removing network $NET_NAME
	docker network remove $NET_NAME
}

# Generates list of params to pass to "docker run" to configure IP addresses
# $1: SUBNET to use, same as passed to network_create()
# $2: Address suffix from SUBNET to apply to the container
docker_network_params() {
	NET=$1
	ADDR_SUFIX=$2
	echo --network $NET_NAME --ip "172.18.$NET.$ADDR_SUFIX" --ip6 "fd02:db8:$NET::$ADDR_SUFIX"
}

fix_perms() {
	if ! docker_image_exists "debian-bullseye-build"; then
		docker_images_require "debian-bullseye-build"
	fi

	echo Fixing permissions
	docker run 	--rm \
			-v $VOL_BASE_DIR:/data \
			-v $CACHE_DIR:/cache \
			--name ${BUILD_TAG}-cleaner \
			$REPO_USER/debian-bullseye-build \
			chmod -R a+rX /data/ /cache/
}

collect_logs() {
	cat "$VOL_BASE_DIR"/*/junit-*.log || true
}

clean_up_common() {
	set +e

	set +x
	echo
	echo "### Clean up ###"
	echo
	set -x

	# Clear trap
	trap - EXIT INT TERM 0

	# Run clean_up() from ttcn3-*/jenkins.sh, if defined
	if type clean_up >/dev/null; then
		clean_up
	fi

	network_clean
	network_remove
	rm -rf "$VOL_BASE_DIR"/unix
	fix_perms
	collect_logs
}

# Run clean up code when the script stops (either by failing command, by ^C, or
# after running through successfully). The caller can define a custom clean_up
# function.
set_clean_up_trap() {
	trap clean_up_common EXIT INT TERM 0
}

docker_kvm_param() {
	if [ "$KERNEL_TEST_KVM" != 0 ]; then
		echo "--device /dev/kvm:/dev/kvm"
	fi
}

# Generate the initrd, and optionally build a kernel, for tests that involve
# kernel modules. Boot the kernel once in QEMU inside docker to verify that it
# works. See README.md for description of the KERNEL_* environment variables.
# $1: kernel config base (e.g. defconfig, tinyconfig, allnoconfig)
# $2: path to kernel config fragment
# $3: path to project specific initrd build script, which adds the osmo
#     program, kernel modules etc. to the initrd (gets sourced by
#     scripts/kernel-test/initrd-build.sh)
# $4: docker image name
# $5-n: (optional) additional arguments to "docker run", like a volume
#       containing a config file
kernel_test_prepare() {
	local kernel_config_base="$1"
	local kernel_config_fragment="$2"
	local initrd_project_script="$3"
	local docker_image="$4"
	shift 4

	# Store KVM availibility in global KERNEL_TEST_KVM
	if [ -z "$KERNEL_TEST_KVM" ]; then
		if [ -e "/dev/kvm" ]; then
			KERNEL_TEST_KVM=1
		else
			KERNEL_TEST_KVM=0
		fi
	fi

	mkdir -p "$CACHE_DIR/kernel-test"

	cp "$kernel_config_fragment" \
		"$CACHE_DIR/kernel-test/fragment.config"
	cp "$initrd_project_script" \
		"$CACHE_DIR/kernel-test/initrd-project-script.sh"

	docker run \
		--cap-add=NET_ADMIN \
		$(docker_kvm_param) \
		--device /dev/net/tun:/dev/net/tun \
		-v "$CACHE_DIR:/cache" \
		-v "$KERNEL_TEST_DIR:/kernel-test:ro" \
		-e "KERNEL_BRANCH=$KERNEL_BRANCH" \
		-e "KERNEL_BUILD=$KERNEL_BUILD" \
		-e "KERNEL_CONFIG_BASE=$kernel_config_base" \
		-e "KERNEL_REMOTE_NAME=$KERNEL_REMOTE_NAME" \
		-e "KERNEL_URL=$KERNEL_URL" \
		"$@" \
		"$docker_image" \
		"/kernel-test/prepare.sh"
}

# Wait until the linux kernel is booted inside QEMU inside docker, and the
# initrd is right before running the project-specific commands (e.g. starting
# osmo-ggsn). This may take a few seconds if running without KVM.
# $1: path to the VM's log file
kernel_test_wait_for_vm() {
	local log="$1"
	local i

	if [ "$KERNEL_TEST" != 1 ]; then
		return
	fi

	for i in $(seq 1 10); do
		sleep 1

		if grep -q KERNEL_TEST_VM_IS_READY "$log"; then
			return
		fi
	done

	# Let clean_up_common kill the VM
	echo "Timeout while waiting for kernel test VM"
	exit 1
}

# Check if IMAGE_SUFFIX starts with "latest" (e.g. "latest-centos8")
image_suffix_is_latest() {
	case "$IMAGE_SUFFIX" in
	latest*) return 0 ;;
	*) return 1 ;;
	esac
}

# Check if IMAGE_SUFFIX starts with "master" (e.g. "master-centos8")
image_suffix_is_master() {
	case "$IMAGE_SUFFIX" in
	master*) return 0 ;;
	*) return 1 ;;
	esac
}

# Write the Osmocom repository to the TTCN3 config file, so the tests may take
# different code paths (OS#5327)
# $1: path to TTCN3 config file (e.g. BSC_Tests.cfg)
write_mp_osmo_repo() {
	local repo="nightly"
	local config="$1"
	local line

	if ! [ -e "$config" ]; then
		set +x
		echo
		echo "ERROR: TTCN3 config file '$config' not found in $PWD"
		echo
		exit 1
	fi

	case "$IMAGE_SUFFIX" in
	latest*)
		repo="latest"
		;;
	20*q*-*)  # e.g. 2021q1-centos8
		repo="$(echo "$IMAGE_SUFFIX" | cut -d- -f 1)"  # e.g. 2021q1
		;;
	*)
		;;
	esac

	line="Misc_Helpers.mp_osmo_repo := \"$repo\""

	sed \
		-i \
		"s/\[MODULE_PARAMETERS\]/\[MODULE_PARAMETERS\]\n$line/g" \
		"$config"
}

set -x

# non-jenkins execution: assume local user name
if [ "x$REPO_USER" = "x" ]; then
	REPO_USER=$USER
fi

if [ "x$WORKSPACE" = "x" ]; then
	# non-jenkins execution: put logs in /tmp
	VOL_BASE_DIR="$(mktemp -d)"

	# point /tmp/logs to the last ttcn3 run
	rm /tmp/logs || true
	ln -s "$VOL_BASE_DIR" /tmp/logs || true
else
	# jenkins execution: put logs in workspace
	VOL_BASE_DIR="$WORKSPACE/logs"
	rm -rf "$VOL_BASE_DIR"
	mkdir -p "$VOL_BASE_DIR"
fi

if [ ! -d "$VOL_BASE_DIR" ]; then
	echo "ERROR: \$VOL_BASE_DIR does not exist: '$VOL_BASE_DIR'"
	exit 1
fi

# non-jenkins execution: set a unique BUILD_TAG to avoid collisions (OS#5358)
if [ "x$BUILD_TAG" = "x" ]; then
	BUILD_TAG="nonjenkins-$(date +%N)"
fi

SUITE_NAME=`basename $PWD`

NET_NAME=$SUITE_NAME
