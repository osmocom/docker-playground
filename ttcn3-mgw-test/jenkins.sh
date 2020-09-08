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

SUBNET=4
network_create $SUBNET

# Disable e1 config options until osmo-mgw >= 1.8.0 release
if [ "$IMAGE_SUFFIX" = "latest" ]; then
       sed -i "s/e1_line.*//" $VOL_BASE_DIR/mgw/osmo-mgw.cfg
       sed -i "s/e1_input.*//" $VOL_BASE_DIR/mgw/osmo-mgw.cfg
       sed -i "s/line 0.*//" $VOL_BASE_DIR/mgw/osmo-mgw.cfg
       # Disable IPv6 until osmo-mgw .git release > 1.7.0 is available
       sed "/fd02:db8/d" -i $VOL_BASE_DIR/mgw/osmo-mgw.cfg
fi

# start container with mgw in background
docker run	--rm \
		$(docker_network_params $SUBNET 180) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name ${BUILD_TAG}-mgw -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-mgw-$IMAGE_SUFFIX

# start docker container with testsuite in foreground
docker run	--rm \
		$(docker_network_params $SUBNET 181) \
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
