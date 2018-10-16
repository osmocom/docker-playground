#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-jessie-build" \
	"osmo-stp-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"sigtran-tests" \
	"sua-test"

mkdir $VOL_BASE_DIR/sua-tester
cp sua-param-testtool-sgp.scm some-sua-sgp-tests.txt $VOL_BASE_DIR/sua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

network_create 172.18.6.0/24

# start container with STP in background
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.6.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp \
		-d $REPO_USER/osmo-stp-$IMAGE_SUFFIX

# start docker container with tests
docker run	--rm \
		--network $NET_NAME --ip 172.18.6.3 \
		-v $VOL_BASE_DIR/sua-tester:/data \
		--name ${BUILD_TAG}-sua-test \
		$REPO_USER/sua-test > $VOL_BASE_DIR/junit-xml-sua.log

docker container stop -t 1 ${BUILD_TAG}-stp

network_remove
collect_logs
