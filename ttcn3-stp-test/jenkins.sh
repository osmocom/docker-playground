#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"ttcn3-stp-test"

mkdir $VOL_BASE_DIR/stp-tester
cp STP_Tests.cfg $VOL_BASE_DIR/stp-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

network_create 172.18.19.0/24

echo Starting container with STP
docker run	--rm \
		--network $NET_NAME --ip 172.18.19.200 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with STP testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.19.203 \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/stp-tester:/data \
		--name ${BUILD_TAG}-ttcn3-stp-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-stp-test

docker container kill ${BUILD_TAG}-stp

network_remove
collect_logs
