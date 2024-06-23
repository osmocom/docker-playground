#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-s1gw-$IMAGE_SUFFIX" \
	"ttcn3-s1gw-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/s1gw-tester
cp S1GW_Tests.cfg $VOL_BASE_DIR/s1gw-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/s1gw-tester/S1GW_Tests.cfg"

mkdir $VOL_BASE_DIR/s1gw
cp s1gw.sh $VOL_BASE_DIR/s1gw/
cp osmo-s1gw.config $VOL_BASE_DIR/s1gw/

network_create
network_replace_subnet_in_configs

echo "Starting container with osmo-s1gw"
docker run	--rm \
		$(docker_network_params $SUBNET 100) \
		--user=root \
		--ulimit core=-1 \
		--cap-add=NET_ADMIN \
		-e "ERL_FLAGS=-config /data/osmo-s1gw.config" \
		-v $VOL_BASE_DIR/s1gw:/data \
		--name ${BUILD_TAG}-s1gw -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-s1gw-$IMAGE_SUFFIX \
		/bin/sh -c "/data/s1gw.sh > /data/osmo-s1gw.log 2>&1"

# Give some time to osmo-s1gw to be fully started; it's a bit slow...
sleep 2

echo "Starting container with the S1GW testsuite"
docker run	--rm \
		$(docker_network_params $SUBNET 101) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/s1gw-tester:/data \
		--name ${BUILD_TAG}-ttcn3-s1gw-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-s1gw-test
