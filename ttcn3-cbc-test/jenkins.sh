#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-cbc-$IMAGE_SUFFIX" \
	"ttcn3-cbc-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/cbc-tester
cp CBC_Tests.cfg $VOL_BASE_DIR/cbc-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/cbc-tester/CBC_Tests.cfg"

mkdir $VOL_BASE_DIR/cbc
cp osmo-cbc.cfg $VOL_BASE_DIR/cbc/

network_create
network_replace_subnet_in_configs

echo Starting container with CBC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/cbc:/data \
		--name ${BUILD_TAG}-cbc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-cbc-$IMAGE_SUFFIX

echo Starting container with CBC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 100) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4264" \
		-v $VOL_BASE_DIR/cbc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-cbc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-cbc-test
