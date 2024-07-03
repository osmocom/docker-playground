#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-sip-$IMAGE_SUFFIX" \
	"ttcn3-sip-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/sip-tester
mkdir $VOL_BASE_DIR/sip-tester/unix
cp SIP_Tests.cfg $VOL_BASE_DIR/sip-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/sip-tester/SIP_Tests.cfg"

mkdir $VOL_BASE_DIR/sip
mkdir $VOL_BASE_DIR/sip/unix
cp osmo-sip-connector.cfg $VOL_BASE_DIR/sip/

mkdir $VOL_BASE_DIR/unix

network_create
network_replace_subnet_in_configs

echo Starting container with osmo-sip-connector
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sip:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-sip-connector -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-sip-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-sip-connector -c /data/osmo-sip-connector.cfg >>/data/osmo-sip-connector.log 2>&1"

echo Starting container with SIP testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.10" \
		-e "OSMO_SUT_PORT=4256" \
		-v $VOL_BASE_DIR/sip-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-sip-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-sip-test
