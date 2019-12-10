#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-stp-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-stp-test"

mkdir $VOL_BASE_DIR/stp-tester
cp STP_Tests.cfg $VOL_BASE_DIR/stp-tester/

mkdir $VOL_BASE_DIR/stp
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	cp latest/osmo-stp.cfg $VOL_BASE_DIR/stp/
else
	cp osmo-stp.cfg $VOL_BASE_DIR/stp/
fi

network_create 172.18.19.0/24

echo Starting container with STP
docker run	--rm \
		--network $NET_NAME --ip 172.18.19.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with STP testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.19.203 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/stp-tester:/data \
		--name ${BUILD_TAG}-ttcn3-stp-test \
		$REPO_USER/ttcn3-stp-test

docker container kill ${BUILD_TAG}-stp

network_remove
collect_logs
