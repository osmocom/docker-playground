#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-mgw-$IMAGE_SUFFIX" \
	"ttcn3-mgw-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/mgw-tester
cp MGCP_Test.cfg $VOL_BASE_DIR/mgw-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/mgw-tester/MGCP_Test.cfg"

mkdir $VOL_BASE_DIR/mgw
cp osmo-mgw.cfg $VOL_BASE_DIR/mgw/
# Can be dropped once released osmo-mgw is >1.10.0:
if ! image_suffix_is_master; then
	sed -i "/^ osmux bind-ip-v6 fd02:db8:4::180/d" $VOL_BASE_DIR/mgw/osmo-mgw.cfg
fi

SUBNET=4
network_create $SUBNET

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
