#!/bin/sh

. ../jenkins-common.sh

network_create 172.18.8.0/24

mkdir $VOL_BASE_DIR/sgsn-tester
cp SGSN_Tests.cfg $VOL_BASE_DIR/sgsn-tester/

mkdir $VOL_BASE_DIR/sgsn
cp osmo-sgsn.cfg $VOL_BASE_DIR/sgsn/

mkdir $VOL_BASE_DIR/unix

echo Starting container with SGSN
docker run	--rm \
		--network $NET_NAME --ip 172.18.8.10 \
		-v $VOL_BASE_DIR/sgsn:/data \
		--name ${BUILD_TAG}-sgsn -d \
		$REPO_USER/osmo-sgsn-master \
		/usr/local/bin/osmo-sgsn

echo Starting container with SGSN testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.8.103 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/sgsn-tester:/data \
		--name ${BUILD_TAG}-ttcn3-sgsn-test \
		$REPO_USER/ttcn3-sgsn-test

echo Stopping containers
docker container kill ${BUILD_TAG}-sgsn

network_remove
collect_logs
