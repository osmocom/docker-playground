#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-buster-build" \
	"sigtran-tests" \
	"osmo-stp-$IMAGE_SUFFIX" \
	"debian-bullseye-titan" \
	"nplab-m3ua-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/m3ua-tester
cp m3ua-param-testtool.scm all-sgp-tests.txt $VOL_BASE_DIR/m3ua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

network_create
network_replace_subnet_in_configs

# start container with STP in background
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp \
		-d $REPO_USER/osmo-stp-$IMAGE_SUFFIX

# start docker container with tests
docker run	--rm \
		$(docker_network_params $SUBNET 2) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/m3ua-tester:/data \
		--name ${BUILD_TAG}-m3ua-test \
		$REPO_USER/nplab-m3ua-test > $VOL_BASE_DIR/m3ua-tester/junit-xml-m3ua.log
