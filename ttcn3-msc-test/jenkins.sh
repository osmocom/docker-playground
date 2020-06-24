#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-msc-$IMAGE_SUFFIX" \
	"ttcn3-msc-test"

network_create 172.18.1.0/24

mkdir $VOL_BASE_DIR/msc-tester
mkdir $VOL_BASE_DIR/msc-tester/unix
cp MSC_Tests.cfg $VOL_BASE_DIR/msc-tester/

# Disable verification of VLR and conn Cell ID until osmo-msc.git release > 1.6.1 is available
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed "s/MSC_Tests.mp_enable_cell_id_test := true/MSC_Tests.mp_enable_cell_id_test := false/" -i \
		"$VOL_BASE_DIR/msc-tester/MSC_Tests.cfg"
fi

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

mkdir $VOL_BASE_DIR/msc
mkdir $VOL_BASE_DIR/msc/unix
cp osmo-msc.cfg $VOL_BASE_DIR/msc/

mkdir $VOL_BASE_DIR/unix

echo Starting container with STP
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.200 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with MSC
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.10 \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/msc:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-msc -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-msc-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-msc -c /data/osmo-msc.cfg >>/data/osmo-msc.log 2>&1"

echo Starting container with MSC testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.1.103 \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/msc-tester:/data \
		-v $VOL_BASE_DIR/unix:/data/unix \
		--name ${BUILD_TAG}-ttcn3-msc-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-msc-test

echo Stopping containers
docker container kill ${BUILD_TAG}-msc
docker container kill ${BUILD_TAG}-stp

network_remove
rm -rf $VOL_BASE_DIR/unix
collect_logs
