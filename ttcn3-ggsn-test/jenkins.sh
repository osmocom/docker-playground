#!/bin/sh
# Environment variables: see README.md
# Possible test configurations:
# * v4_only: one APN with v4
# * v6_only: one APN with v6
# * v4v6_only: one APN with v4v6
# * all: multiple APNs with all of the above
TEST_CONFIGS_ALL="all v4_only v6_only v4v6_only"
TEST_CONFIGS="${TEST_CONFIGS:-$TEST_CONFIGS_ALL}"
. ../jenkins-common.sh

KERNEL_TEST="${KERNEL_TEST:-0}"
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-ggsn-$IMAGE_SUFFIX" \
	"ttcn3-ggsn-test"

set_clean_up_trap
set -e

clean_up() {
	local i
	local log

	# Add a suffix to the class names in the junit-xml log
	for i in $TEST_CONFIGS; do
		if [ "$i" = "all" ]; then
			continue
		fi

		for log in "$VOL_BASE_DIR"/ggsn-tester-"$i"/junit-xml-*.log; do
			if ! [ -e "$log" ]; then
				continue
			fi
			sed -i "s/classname='\([^']\+\)'/classname='\1_$i'/g" "$log"
		done
	done
}

# Start container with ggsn in background
start_ggsn() {
	local test_config="$1"

	GGSN_CMD="osmo-ggsn -c /data/osmo-ggsn.cfg"
	GGSN_DOCKER_ARGS=""
	if [ "$KERNEL_TEST" = "1" ]; then
		cp osmo-ggsn-kernel/initrd-ggsn.sh $VOL_BASE_DIR/ggsn-"$test_config"/
		network_replace_subnet_in_configs

		kernel_test_prepare \
			"defconfig" \
			"osmo-ggsn-kernel/fragment.config" \
			"$VOL_BASE_DIR/ggsn-$test_config/initrd-ggsn.sh" \
			"$REPO_USER/osmo-ggsn-$IMAGE_SUFFIX" \
			-v $VOL_BASE_DIR/ggsn-"$test_config":/data

		GGSN_CMD="/kernel-test/run-qemu.sh"
		GGSN_DOCKER_ARGS="
			$(docker_network_params $SUBNET 200)
			$(docker_kvm_param)
			-v "$KERNEL_TEST_DIR:/kernel-test:ro"
			-v "$CACHE_DIR:/cache"
			"
		OSMO_SUT_HOST="$SUB4_PREFIX.$SUBNET.200"
	else

		GGSN_DOCKER_ARGS="
			$(docker_network_params $SUBNET 201)
			"
		OSMO_SUT_HOST="$SUB4_PREFIX.$SUBNET.201"
	fi
	docker run	--rm \
			--cap-add=NET_ADMIN \
			--device /dev/net/tun:/dev/net/tun \
			--sysctl net.ipv6.conf.all.disable_ipv6=0 \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/ggsn-"$test_config":/data \
			--name ${BUILD_TAG}-ggsn -d \
			$DOCKER_ARGS \
			$GGSN_DOCKER_ARGS \
			$REPO_USER/osmo-ggsn-$IMAGE_SUFFIX \
			/bin/sh -c "$GGSN_CMD >/data/osmo-ggsn.log 2>&1"

	kernel_test_wait_for_vm "$VOL_BASE_DIR/ggsn-$test_config/osmo-ggsn.log"
}

# Start docker container with testsuite in foreground
start_testsuite() {
	local test_config="$1"

	docker run	--rm \
			--sysctl net.ipv6.conf.all.disable_ipv6=0 \
			$(docker_network_params $SUBNET 202) \
			--ulimit core=-1 \
			-v $VOL_BASE_DIR/ggsn-tester-"$test_config":/data \
			-e "TTCN3_PCAP_PATH=/data" \
			-e "OSMO_SUT_HOST=$OSMO_SUT_HOST" \
			-e "OSMO_SUT_PORT=4260" \
			--name ${BUILD_TAG}-ggsn-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-ggsn-test
}

network_create

if [ "$KERNEL_TEST" = 1 ]; then
	CONFIGS_DIR="osmo-ggsn-kernel"
else
	CONFIGS_DIR="osmo-ggsn"
fi

for i in $TEST_CONFIGS; do
	# OS#6106: Currently it is not possible to configure multiple APNs with
	# gtpu-mode kernel-gtp in OsmoGGSN, because it cannot share the GTP-U
	# bind socket between tunnels.
	if [ "$i" = "all" ] && [ "$KERNEL_TEST" = "1" ]; then
		continue
	fi

	mkdir $VOL_BASE_DIR/ggsn-tester-"$i"
	cp ttcn3/"$i"/GGSN_Tests.cfg $VOL_BASE_DIR/ggsn-tester-"$i"/GGSN_Tests.cfg
	write_mp_osmo_repo "$VOL_BASE_DIR/ggsn-tester-$i/GGSN_Tests.cfg"

	mkdir $VOL_BASE_DIR/ggsn-"$i"
	cp "$CONFIGS_DIR"/"$i"/osmo-ggsn.cfg "$VOL_BASE_DIR"/ggsn-"$i"/osmo-ggsn.cfg
	network_replace_subnet_in_configs

	start_ggsn "$i"
	start_testsuite "$i"

	docker_kill_wait "$BUILD_TAG"-ggsn || true
done
