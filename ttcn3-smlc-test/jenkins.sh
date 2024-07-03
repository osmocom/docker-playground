#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-smlc-$IMAGE_SUFFIX" \
	"ttcn3-smlc-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/smlc-tester
cp SMLC_Tests.cfg $VOL_BASE_DIR/smlc-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/smlc-tester/SMLC_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/smlc
cp osmo-smlc.cfg $VOL_BASE_DIR/smlc/

network_create
network_replace_subnet_in_configs

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		--ulimit core=-1 \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with SMLC
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/smlc:/data \
		--name ${BUILD_TAG}-smlc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-smlc-$IMAGE_SUFFIX

echo Starting container with SMLC testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4271" \
		-v $VOL_BASE_DIR/smlc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-smlc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-smlc-test
