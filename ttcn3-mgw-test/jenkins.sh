#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-mgw-$IMAGE_SUFFIX" \
	"ttcn3-mgw-test"

mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/

network_create 172.18.4.0/24

# start container with mgw in background
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.180 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name ${BUILD_TAG}-mgw -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-mgw-$IMAGE_SUFFIX

# start docker container with testsuite in foreground
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.181 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mgw-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ttcn3-mgw-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-mgw-test

# stop mgw after test has completed
docker container stop ${BUILD_TAG}-mgw

network_remove
collect_logs
