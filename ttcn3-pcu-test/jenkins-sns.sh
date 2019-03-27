#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-pcu-test"

network_create 172.18.14.0/24

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp sns/PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp sns/osmo-pcu.cfg $VOL_BASE_DIR/pcu/

mkdir $VOL_BASE_DIR/unix

echo Starting container with PCU
docker run	--rm \
		--network $NET_NAME --ip 172.18.14.101 \
		-v $VOL_BASE_DIR/pcu:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-pcu-sns -d \
		$REPO_USER/osmo-pcu-$IMAGE_SUFFIX \
		/usr/local/bin/respawn.sh osmo-pcu -c /data/osmo-pcu.cfg

echo Starting container with PCU testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.14.10 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pcu-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-pcu-test-sns \
		$REPO_USER/ttcn3-pcu-test

echo Stopping containers
docker container kill ${BUILD_TAG}-pcu-sns

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
