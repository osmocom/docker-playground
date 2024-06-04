#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"asterisk-$IMAGE_SUFFIX" \
	"ttcn3-asterisk-ims-ue-test" \
	"dnsmasq"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/dnsmasq
cp dnsmasq/* $VOL_BASE_DIR/dnsmasq/

mkdir $VOL_BASE_DIR/asterisk-ims-ue-tester
mkdir $VOL_BASE_DIR/asterisk-ims-ue-tester/unix
cp Asterisk_Tests.cfg $VOL_BASE_DIR/asterisk-ims-ue-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/asterisk-ims-ue-tester/Asterisk_Tests.cfg"

mkdir $VOL_BASE_DIR/asterisk
cp asterisk/* $VOL_BASE_DIR/asterisk/

network_create
network_replace_subnet_in_configs

echo Starting container with dnsmasq
docker run	--rm \
		--cap-add=NET_ADMIN \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/dnsmasq:/data \
		--name ${BUILD_TAG}-dnsmasq -d \
		$DOCKER_ARGS \
		$REPO_USER/dnsmasq

echo Starting container with Asterisk
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_RESOURCE \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/asterisk:/data \
		--name ${BUILD_TAG}-asterisk -d \
		$DOCKER_ARGS \
		$REPO_USER/asterisk-$IMAGE_SUFFIX \
		/bin/sh -c "/data/asterisk.sh >/data/asterisk.console.log 2>&1"

# Leave some time for asterisk to start:
sleep 3

echo Starting container with Asterisk testsuite
docker run	--rm \
		--cap-add=NET_ADMIN \
		--cap-add=SYS_RESOURCE \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/asterisk-ims-ue-tester:/data \
		--name ${BUILD_TAG}-ttcn3-asterisk-ims-ue-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-asterisk-ims-ue-test
