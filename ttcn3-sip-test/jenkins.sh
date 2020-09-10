#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-sip-$IMAGE_SUFFIX" \
	"ttcn3-sip-test"

SUBNET=11
network_create $SUBNET

mkdir $VOL_BASE_DIR/sip-tester
mkdir $VOL_BASE_DIR/sip-tester/unix
cp SIP_Tests.cfg $VOL_BASE_DIR/sip-tester/

# Can be removed once osmo-sip-connector > 1.4.1 is available
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed "s/MNCC_Emulation.mp_mncc_version := 7/MNCC_Emulation.mp_mncc_version := 6/" -i \
		"$VOL_BASE_DIR/sip-tester/SIP_Tests.cfg"
fi

mkdir $VOL_BASE_DIR/sip
mkdir $VOL_BASE_DIR/sip/unix
cp osmo-sip-connector.cfg $VOL_BASE_DIR/sip/

mkdir $VOL_BASE_DIR/unix

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
		-v $VOL_BASE_DIR/sip-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-sip-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-sip-test

echo Stopping containers
docker container kill ${BUILD_TAG}-sip-connector

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
