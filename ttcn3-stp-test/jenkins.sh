#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"ttcn3-stp-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/stp-tester
cp STP_Tests.cfg $VOL_BASE_DIR/stp-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/stp-tester/STP_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

network_create
network_replace_subnet_in_configs

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with STP testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.200" \
		-e "OSMO_SUT_PORT=4239" \
		-v $VOL_BASE_DIR/stp-tester:/data \
		--name ${BUILD_TAG}-ttcn3-stp-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-stp-test
