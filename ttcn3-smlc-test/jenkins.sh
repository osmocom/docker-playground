#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-smlc-$IMAGE_SUFFIX" \
	"ttcn3-smlc-test"

set_clean_up_trap

mkdir $VOL_BASE_DIR/smlc-tester
cp SMLC_Tests.cfg $VOL_BASE_DIR/smlc-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/smlc
cp osmo-smlc.cfg $VOL_BASE_DIR/smlc/

SUBNET=23
network_create $SUBNET

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
		-v $VOL_BASE_DIR/smlc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-smlc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-smlc-test
