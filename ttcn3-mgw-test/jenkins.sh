#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-mgw-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-mgw-test"

mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/
# conn-timeout must be disabled until release AFTER osmo-mgw 1.5.0 is tagged
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed "s/mp_enable_conn_timeout_test := true;/mp_enable_conn_timeout_test := false;/g" -i $VOL_BASE_DIR/mgw-tester/MGCP_Test.cfg
fi

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/

network_create 172.18.4.0/24

# start container with mgw in background
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.180 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name ${BUILD_TAG}-mgw -d \
		$REPO_USER/osmo-mgw-$IMAGE_SUFFIX

# start docker container with testsuite in foreground
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.181 \
		-v $VOL_BASE_DIR/mgw-tester:/data \
		-e "TTCN3_PCAP_PATH=/data" \
		--name ${BUILD_TAG}-ttcn3-mgw-test \
		$REPO_USER/ttcn3-mgw-test

# stop mgw after test has completed
docker container stop ${BUILD_TAG}-mgw

network_remove
collect_logs
