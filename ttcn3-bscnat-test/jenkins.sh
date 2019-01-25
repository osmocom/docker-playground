#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-jessie-build" \
	"osmo-nitb-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-bscnat-test"


mkdir $VOL_BASE_DIR/bscnat-tester
cp BSCNAT_Tests.cfg $VOL_BASE_DIR/bscnat-tester/

mkdir $VOL_BASE_DIR/bscnat
cp osmo-bsc-nat.cfg $VOL_BASE_DIR/bscnat/
cp bscs.config $VOL_BASE_DIR/bscnat/

network_create 172.18.11.0/24

echo Starting container with BSCNAT
docker run	--rm \
		--network $NET_NAME --ip 172.18.11.20 \
		-v $VOL_BASE_DIR/bscnat:/data \
		--name ${BUILD_TAG}-bscnat -d \
		$REPO_USER/osmo-nitb-$IMAGE_SUFFIX osmo-bsc_nat -c /data/osmo-bsc-nat.cfg

echo Starting container with BSCNAT testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.11.203 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/bscnat-tester:/data \
		--name ${BUILD_TAG}-ttcn3-bscnat-test \
		$REPO_USER/ttcn3-bscnat-test

echo Stopping containers
docker container kill ${BUILD_TAG}-bscnat

network_remove
collect_logs
