#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-ns-$IMAGE_SUFFIX" \
	"ttcn3-ns-test"

set_clean_up_trap
set -e

SUBNET=32
network_create $SUBNET

mkdir $VOL_BASE_DIR/ns-tester
cp sgsn-sns/NS_Tests.cfg $VOL_BASE_DIR/ns-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/ns-tester/NS_Tests.cfg"

mkdir $VOL_BASE_DIR/ns
cp sgsn-sns/osmo-ns-dummy.cfg $VOL_BASE_DIR/ns/

echo Starting container with osmo-ns-dummy
docker run	--rm \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/ns:/data \
		--name ${BUILD_TAG}-ns-sgsn-sns -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-ns-$IMAGE_SUFFIX \
		/bin/sh -c "/usr/local/bin/osmo-ns-dummy -c /data/osmo-ns-dummy.cfg -p 4240 >>/data/osmo-ns-dummy.log 2>&1"

echo Starting container with NS testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/ns-tester:/data \
		--name ${BUILD_TAG}-ttcn3-ns-test-sgsn-sns \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-ns-test
