#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-sip-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-sip-test"

network_create 172.18.11.0/24

mkdir $VOL_BASE_DIR/sip-tester
mkdir $VOL_BASE_DIR/sip-tester/unix
cp SIP_Tests.cfg $VOL_BASE_DIR/sip-tester/

mkdir $VOL_BASE_DIR/sip
mkdir $VOL_BASE_DIR/sip/unix
cp osmo-sip-connector.cfg $VOL_BASE_DIR/sip/

mkdir $VOL_BASE_DIR/unix

echo Starting container with osmo-sip-connector
docker run	--rm \
		--network $NET_NAME --ip 172.18.11.10 \
		-v $VOL_BASE_DIR/sip:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-sip-connector -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-sip-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-sip-connector -c /data/osmo-sip-connector.cfg >>/data/osmo-sip-connector.log 2>&1"

echo Starting container with SIP testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.11.103 \
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
