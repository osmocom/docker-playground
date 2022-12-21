#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-upf-$IMAGE_SUFFIX" \
	"ttcn3-upf-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/upf-tester
cp UPF_Tests.cfg $VOL_BASE_DIR/upf-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/upf-tester/UPF_Tests.cfg"

mkdir $VOL_BASE_DIR/upf
cp osmo-upf.cfg $VOL_BASE_DIR/upf/

network_create
network_replace_subnet_in_configs

echo Starting container with UPF
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/upf:/data \
		--name ${BUILD_TAG}-upf -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-upf-$IMAGE_SUFFIX

echo Starting container with UPF testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/upf-tester:/data \
		--name ${BUILD_TAG}-ttcn3-upf-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-upf-test
