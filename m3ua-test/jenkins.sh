#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-jessie-build" \
	"osmo-stp-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"m3ua-test"

mkdir $VOL_BASE_DIR/m3ua-tester
cp m3ua-param-testtool.scm all-sgp-tests.txt $VOL_BASE_DIR/m3ua-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

network_create 172.18.7.0/24

# start container with STP in background
docker run	--rm \
		--sysctl net.ipv6.conf.all.disable_ipv6=0 \
		--network $NET_NAME --ip 172.18.7.200 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp \
		-d $REPO_USER/osmo-stp-$IMAGE_SUFFIX

# start docker container with tests
docker run	--rm \
		--network $NET_NAME --ip 172.18.7.2 \
		-v $VOL_BASE_DIR/m3ua-tester:/data \
		--name ${BUILD_TAG}-m3ua-test \
		$REPO_USER/m3ua-test > $WORKSPACE/logs/junit-xml-m3ua.log

docker container stop -t 1 ${BUILD_TAG}-stp

network_remove
collect_logs
