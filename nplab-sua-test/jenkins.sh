#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-stp-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"sigtran-tests" \
	"nplab-sua-test"

set_clean_up_trap
set -e

mkdir $VOL_BASE_DIR/sua-tester
cp sua-param-testtool-sgp.scm some-sua-sgp-tests.txt $VOL_BASE_DIR/sua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

SUBNET=6
network_create $SUBNET

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
		$(docker_network_params $SUBNET 3) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/sua-tester:/data \
		--name ${BUILD_TAG}-sua-test \
		$REPO_USER/nplab-sua-test > $VOL_BASE_DIR/sua-tester/junit-xml-sua.log
