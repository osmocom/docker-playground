#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-hnodeb-$IMAGE_SUFFIX" \
	"ttcn3-hnodeb-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/hnodeb-tester
mkdir $VOL_BASE_DIR/hnodeb-tester/unix
cp HNB_Tests.cfg $VOL_BASE_DIR/hnodeb-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/hnodeb-tester/HNB_Tests.cfg"

mkdir $VOL_BASE_DIR/hnodeb
mkdir $VOL_BASE_DIR/hnodeb/unix
cp osmo-hnodeb.cfg $VOL_BASE_DIR/hnodeb/

mkdir $VOL_BASE_DIR/unix

network_create
network_replace_subnet_in_configs

echo Starting container with HNodeB
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hnodeb:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-hnodeb -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-hnodeb-$IMAGE_SUFFIX

echo Starting container with HNodeB testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4273" \
		-v $VOL_BASE_DIR/hnodeb-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-hnodeb-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-hnodeb-test

echo Stopping containers
docker_kill_wait ${BUILD_TAG}-hnodeb
