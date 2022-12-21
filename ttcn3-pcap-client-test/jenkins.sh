#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-pcap-$IMAGE_SUFFIX" \
	"ttcn3-pcap-client-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/pcap-client-tester
cp OPCAP_CLIENT_Tests.cfg $VOL_BASE_DIR/pcap-client-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/pcap-client-tester/OPCAP_CLIENT_Tests.cfg"

mkdir $VOL_BASE_DIR/pcap-client
cp osmo-pcap-client.cfg $VOL_BASE_DIR/pcap-client/

network_create
network_replace_subnet_in_configs

echo Starting container with pcap-client
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/pcap-client:/data \
		--name ${BUILD_TAG}-pcap-client -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-pcap-$IMAGE_SUFFIX

echo Starting container with pcap-client testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pcap-client-tester:/data \
		--name ${BUILD_TAG}-ttcn3-pcap-client-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-pcap-client-test
