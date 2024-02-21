#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-epdg-$IMAGE_SUFFIX" \
	"ttcn3-epdg-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/epdg-tester
cp EPDG_Tests.cfg $VOL_BASE_DIR/epdg-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/epdg-tester/EPDG_Tests.cfg"

mkdir $VOL_BASE_DIR/epdg
cp osmo-epdg.config $VOL_BASE_DIR/epdg/

network_create
network_replace_subnet_in_configs

echo Starting container with osmo-epdg
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		-u root \
		--ulimit core=-1 \
		--cap-add=NET_ADMIN \
		--device /dev/net/tun:/dev/net/tun \
		-v $VOL_BASE_DIR/epdg:/data \
		--name ${BUILD_TAG}-epdg -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-epdg-$IMAGE_SUFFIX

# Give some time to osmo-epdg to be fully started; it's a bit slow...
sleep 2

echo Starting container with EPDG testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/epdg-tester:/data \
		--name ${BUILD_TAG}-ttcn3-epdg-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-epdg-test
