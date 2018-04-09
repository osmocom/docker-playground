#!/bin/sh

. ../jenkins-common.sh

network_create 172.18.10.0/24

mkdir $VOL_BASE_DIR/hlr-tester
cp HLR_Tests.cfg $VOL_BASE_DIR/hlr-tester/

mkdir $VOL_BASE_DIR/hlr
cp osmo-hlr.cfg $VOL_BASE_DIR/hlr/

echo Starting container with HLR
docker run	--rm \
		--network $NET_NAME --ip 172.18.10.20 \
		-v $VOL_BASE_DIR/hlr:/data \
		--name ${BUILD_TAG}-hlr -d \
		$REPO_USER/osmo-hlr-master \
		/usr/local/bin/osmo-hlr

echo Starting container with HLR testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.10.103 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/hlr-tester:/data \
		--name ${BUILD_TAG}-ttcn3-hlr-test \
		$REPO_USER/ttcn3-hlr-test

echo Stopping containers
docker container kill ${BUILD_TAG}-hlr

network_remove
collect_logs
