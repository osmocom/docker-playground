#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo_dia2gsup-$IMAGE_SUFFIX" \
	"ttcn3-dia2gsup-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/dia2gsup-tester
cp DIA2GSUP_Tests.cfg $VOL_BASE_DIR/dia2gsup-tester/
write_mp_osmo_repo "$VOL_BASE_DIR/dia2gsup-tester/DIA2GSUP_Tests.cfg"

mkdir $VOL_BASE_DIR/dia2gsup
cp osmo_dia2gsup.config $VOL_BASE_DIR/dia2gsup/

network_create
network_replace_subnet_in_configs

echo Starting container with osmo_dia2gsup
docker run	--rm \
		$(docker_network_params $SUBNET 20) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/dia2gsup:/data \
		--name ${BUILD_TAG}-dia2gsup -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo_dia2gsup-$IMAGE_SUFFIX

echo Starting container with DIA2GSUP testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 103) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/dia2gsup-tester:/data \
		--name ${BUILD_TAG}-ttcn3-dia2gsup-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-dia2gsup-test
