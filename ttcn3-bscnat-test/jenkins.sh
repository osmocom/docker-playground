#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-nitb-$IMAGE_SUFFIX" \
	"ttcn3-bscnat-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/bscnat-tester
cp BSCNAT_Tests.cfg $VOL_BASE_DIR/bscnat-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/bscnat-tester/BSCNAT_Tests.cfg"

mkdir $VOL_BASE_DIR/bscnat
cp osmo-bsc-nat.cfg $VOL_BASE_DIR/bscnat/
cp bscs.config $VOL_BASE_DIR/bscnat/

network_create
network_replace_subnet_in_configs

echo Starting container with BSCNAT
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/bscnat:/data \
		--name ${BUILD_TAG}-bscnat -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-nitb-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-bsc_nat -c /data/osmo-bsc-nat.cfg >/data/osmo-bsc-nat.log 2>&1"

echo Starting container with BSCNAT testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/bscnat-tester:/data \
		--name ${BUILD_TAG}-ttcn3-bscnat-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-bscnat-test
