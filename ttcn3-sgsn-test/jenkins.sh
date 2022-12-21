#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-sgsn-$IMAGE_SUFFIX" \
	"ttcn3-sgsn-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/sgsn-tester
cp SGSN_Tests.cfg $VOL_BASE_DIR/sgsn-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/sgsn-tester/SGSN_Tests.cfg"

mkdir $VOL_BASE_DIR/sgsn
cp osmo-sgsn.cfg $VOL_BASE_DIR/sgsn/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/unix

network_create
network_replace_subnet_in_configs

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with SGSN
docker run	--rm \
		$(docker_network_params $SUBNET 10) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sgsn:/data \
		--name ${BUILD_TAG}-sgsn -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-sgsn-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-sgsn -c /data/osmo-sgsn.cfg >/data/osmo-sgsn.log 2>&1"

echo Starting container with SGSN testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-e "OSMO_SUT_HOST=172.18.$SUBNET.10" \
		-e "OSMO_SUT_PORT=4245" \
		-v $VOL_BASE_DIR/sgsn-tester:/data \
		--name ${BUILD_TAG}-ttcn3-sgsn-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-sgsn-test
