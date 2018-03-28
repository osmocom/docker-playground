#!/bin/sh

. ../jenkins-common.sh

VOL_BASE_DIR=`mktemp -d`
mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/

network_create 172.18.4.0/24

# start container with mgw in background
docker run	--rm \
		--network $NET_NAME --ip 172.18.4.180 \
		-v $VOL_BASE_DIR/mgw:/data \
		--name ${BUILD_TAG}-mgw -d \
		$REPO_USER/osmo-mgw-master

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

rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs
cp -a $VOL_BASE_DIR/* $WORKSPACE/logs/
cat $WORKSPACE/logs/mgw-tester/junit-*.log || true
