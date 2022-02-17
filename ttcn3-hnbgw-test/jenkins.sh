#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-hnbgw-$IMAGE_SUFFIX" \
	"ttcn3-hnbgw-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/hnbgw-tester
mkdir $VOL_BASE_DIR/hnbgw-tester/unix
cp HNBGW_Tests.cfg $VOL_BASE_DIR/hnbgw-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/hnbgw-tester/HNBGW_Tests.cfg"

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/hnbgw
mkdir $VOL_BASE_DIR/hnbgw/unix
cp osmo-hnbgw.cfg $VOL_BASE_DIR/hnbgw/

mkdir $VOL_BASE_DIR/unix

SUBNET=35
network_create $SUBNET

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with HNBGW
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hnbgw:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-hnbgw -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-hnbgw-$IMAGE_SUFFIX

echo Starting container with HNBGW testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/hnbgw-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-hnbgw-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-hnbgw-test

echo Stopping containers
docker container kill ${BUILD_TAG}-hnbgw
docker container kill ${BUILD_TAG}-stp
