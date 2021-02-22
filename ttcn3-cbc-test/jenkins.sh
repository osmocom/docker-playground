#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-cbc-$IMAGE_SUFFIX" \
	"ttcn3-cbc-test"

mkdir $VOL_BASE_DIR/cbc-tester
cp CBC_Tests.cfg $VOL_BASE_DIR/cbc-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/cbc
cp osmo-cbc.cfg $VOL_BASE_DIR/cbc/

SUBNET=27
network_create $SUBNET

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
		-v $VOL_BASE_DIR/cbc-tester:/data \
		--name ${BUILD_TAG}-ttcn3-cbc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-cbc-test

echo Stopping containers
docker container kill ${BUILD_TAG}-cbc

network_remove
collect_logs
