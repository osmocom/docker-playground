#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-hlr-$IMAGE_SUFFIX" \
	"ttcn3-hlr-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/hlr-tester
cp HLR_Tests.cfg $VOL_BASE_DIR/hlr-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/hlr-tester/HLR_Tests.cfg"

mkdir $VOL_BASE_DIR/hlr
cp osmo-hlr.cfg $VOL_BASE_DIR/hlr/

network_create
network_replace_subnet_in_configs

echo Starting container with HLR
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/hlr:/data \
		--name ${BUILD_TAG}-hlr -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-hlr-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-hlr -c /data/osmo-hlr.cfg >/data/osmo-hlr.log 2>&1"

echo Starting container with HLR testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=$SUB4_PREFIX.$SUBNET.20" \
		-e "OSMO_SUT_PORT=4258" \
		-v $VOL_BASE_DIR/hlr-tester:/data \
		--name ${BUILD_TAG}-ttcn3-hlr-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-hlr-test
