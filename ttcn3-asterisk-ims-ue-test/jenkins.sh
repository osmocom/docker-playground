#!/bin/sh

TEST_CONFIGS_ALL="ipv4 ipv6"
TEST_CONFIGS="${TEST_CONFIGS:-$TEST_CONFIGS_ALL}"

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"asterisk-$IMAGE_SUFFIX" \
	"ttcn3-asterisk-ims-ue-test" \
	"dnsmasq"

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

		for log in "$VOL_BASE_DIR"/asterisk-ims-ue-tester-"$i"/junit-xml-*.log; do
			if ! [ -e "$log" ]; then
				continue
			fi
			sed -i "s/classname='\([^']\+\)'/classname='\1_$i'/g" "$log"
		done
	done
}

# Start container with dnsmasq in background
start_dnsmasq() {
	local test_config="$1"
	echo Starting container with dnsmasq
	docker run	--rm \
			--cap-add=NET_ADMIN \
			$(docker_network_params $SUBNET $DNS_IP_SUFFIX) \
			--ulimit core=-1 \
			-v "$VOL_BASE_DIR/dnsmasq-${test_config}:/data" \
			--name ${BUILD_TAG}-dnsmasq -d \
			$DOCKER_ARGS \
			$REPO_USER/dnsmasq
}

# Start container with Asterisk in background
start_asterisk() {
	local test_config="$1"
	echo Starting container with Asterisk
	docker run	--rm \
			--cap-add=NET_ADMIN \
			--cap-add=SYS_RESOURCE \
			$(docker_network_params $SUBNET $ASTERISK_IP_SUFFIX) \
			-e "DNS_IPADDR=${DNS_IPADDR}" \
			--ulimit core=-1 \
			-v "$VOL_BASE_DIR/asterisk-${test_config}:/data" \
			--name "${BUILD_TAG}-asterisk" -d \
			$DOCKER_ARGS \
			"$REPO_USER/asterisk-$IMAGE_SUFFIX" \
			/bin/sh -c "/data/asterisk.sh >/data/asterisk.console.log 2>&1"
}

# Start docker container with testsuite in foreground
start_testsuite() {
	local test_config="$1"
	echo Starting container with Asterisk testsuite
	docker run	--rm \
			--cap-add=NET_ADMIN \
			--cap-add=SYS_RESOURCE \
			$(docker_network_params $SUBNET $TTCN3_IP_SUFFIX) \
			--ulimit core=-1 \
			-e "TTCN3_PCAP_PATH=/data" \
			-e "EXTRA_IPADDR=${EXTRA_IPADDR}" \
			-e "ASTERISK_IPADDR=${ASTERISK_IPADDR}" \
			-v "$VOL_BASE_DIR/asterisk-ims-ue-tester-${test_config}:/data" \
			--name "${BUILD_TAG}-ttcn3-asterisk-ims-ue-test" \
			$DOCKER_ARGS \
			"$REPO_USER/ttcn3-asterisk-ims-ue-test" \
			/data/ttcn3.sh
}

network_create

for i in $TEST_CONFIGS; do
	if ! test_config_enabled "$i"; then
		continue
	fi

	mkdir "${VOL_BASE_DIR}/dnsmasq-${i}"
	cp dnsmasq/* "${VOL_BASE_DIR}/dnsmasq-${i}/"

	mkdir "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}"
	mkdir "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}/unix"
	cp "ttcn3/ttcn3.sh" "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}/"
	cp "ttcn3/Asterisk_Tests.cfg" "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}/"
	write_mp_osmo_repo "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}/Asterisk_Tests.cfg"

	mkdir "$VOL_BASE_DIR/asterisk-${i}"
	cp asterisk/* "$VOL_BASE_DIR/asterisk-${i}/"

	network_replace_subnet_in_configs
	ASTERISK_IP_SUFFIX="10"
	TTCN3_IP_SUFFIX="103"
	IMSCORE_IP_SUFFIX="104"
	DNS_IP_SUFFIX="200"

	if [ "$i" = "ipv4" ]; then
		NETMASK_PREFIX="24"
		SUBNET_IP_PREFIX="$SUB4_PREFIX.$SUBNET"
		ASTERISK_IPADDR="${SUBNET_IP_PREFIX}.${ASTERISK_IP_SUFFIX}"
		DNS_IPADDR="${SUBNET_IP_PREFIX}.${DNS_IP_SUFFIX}"
		EXTRA_IPADDR="${SUBNET_IP_PREFIX}.${IMSCORE_IP_SUFFIX}/${NETMASK_PREFIX}"
	elif [ "$i" = "ipv6" ]; then
		NETMASK_PREFIX="64"
		SUBNET_IP_PREFIX="$SUB6_PREFIX:$SUBNET"
		ASTERISK_IPADDR="${SUBNET_IP_PREFIX}::${ASTERISK_IP_SUFFIX}"
		DNS_IPADDR="${SUBNET_IP_PREFIX}::${DNS_IP_SUFFIX}"
		EXTRA_IPADDR="${SUBNET_IP_PREFIX}::${IMSCORE_IP_SUFFIX}/${NETMASK_PREFIX}"

		# Replace IPv4 addresses with IPv6 ones:
		REPLACE_V4_TO_V6_EXPR="s,${SUB4_PREFIX}\.${SUBNET}\.,${SUB6_PREFIX}:${SUBNET}::,g"
		REPLACE_V4_TO_V6_PORT_EXPR="s,${SUB4_PREFIX}\.${SUBNET}\.${ASTERISK_IP_SUFFIX}:,[${ASTERISK_IPADDR}]:,g"
		sed -i -E -e "${REPLACE_V4_TO_V6_EXPR}" "${VOL_BASE_DIR}/dnsmasq-${i}"/*.conf
		sed -i -E -e "s,${SUB4_PREFIX}\.${SUBNET}\.${TTCN3_IP_SUFFIX}/24,${SUB6_PREFIX}:${SUBNET}::${TTCN3_IP_SUFFIX}/${NETMASK_PREFIX},g" "${VOL_BASE_DIR}/asterisk-${i}"/manager.conf
		sed -i -E -e "s,${SUB4},${SUB6},g" "${VOL_BASE_DIR}/asterisk-${i}"/*.conf
		sed -i -E -e "${REPLACE_V4_TO_V6_PORT_EXPR}" "${VOL_BASE_DIR}/asterisk-${i}"/*.conf
		sed -i -E -e "${REPLACE_V4_TO_V6_EXPR}" "${VOL_BASE_DIR}/asterisk-${i}"/*.conf
		sed -i -E -e "${REPLACE_V4_TO_V6_EXPR}" "${VOL_BASE_DIR}/asterisk-ims-ue-tester-${i}"/*.cfg
	fi

	start_dnsmasq "$i"
	start_asterisk "$i"
	start_testsuite "$i"

	docker_kill_wait "$BUILD_TAG"-asterisk || true
	docker_kill_wait "$BUILD_TAG"-dnsmasq || true
	 # For some reason we need to wait a bit until recreating dnsmasq docker,
	 # otherwise it says "container name X  is already in use by container Y":
	sleep 1
done
