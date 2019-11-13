#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-pcu-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-pcu-test"

network_create 172.18.13.0/24

mkdir $VOL_BASE_DIR/pcu-tester
mkdir $VOL_BASE_DIR/pcu-tester/unix
cp PCU_Tests.cfg $VOL_BASE_DIR/pcu-tester/

mkdir $VOL_BASE_DIR/pcu
mkdir $VOL_BASE_DIR/pcu/unix
cp osmo-pcu.cfg $VOL_BASE_DIR/pcu/
# Latest release of osmo-pcu (0.7.0) doesn't know some gsmtap categories
# This can be removed once a new osmo-pcu version is released
if [ "$IMAGE_SUFFIX" = "latest" ]; then
        sed "s/gsmtap-category dl-agch//g" -i $VOL_BASE_DIR/pcu/osmo-pcu.cfg
        sed "s/gsmtap-category dl-pch//g" -i $VOL_BASE_DIR/pcu/osmo-pcu.cfg
        sed "s/gsmtap-category ul-rach//g" -i $VOL_BASE_DIR/pcu/osmo-pcu.cfg
fi

mkdir $VOL_BASE_DIR/unix

echo Starting container with PCU
docker run	--rm \
		--network $NET_NAME --ip 172.18.13.101 \
		-v $VOL_BASE_DIR/pcu:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-pcu -d \
		$REPO_USER/osmo-pcu-$IMAGE_SUFFIX \
		/bin/sh -c "/usr/local/bin/respawn.sh osmo-pcu -c /data/osmo-pcu.cfg -i 172.18.13.10 >>/data/osmo-pcu.log 2>&1"

echo Starting container with PCU testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.13.10 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/pcu-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-pcu-test \
		$REPO_USER/ttcn3-pcu-test

echo Stopping containers
docker container kill ${BUILD_TAG}-pcu

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
