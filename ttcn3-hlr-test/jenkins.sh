#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"debian-stretch-build" \
	"osmo-hlr-$IMAGE_SUFFIX" \
	"debian-stretch-titan" \
	"ttcn3-hlr-test"

network_create 172.18.10.0/24

mkdir $VOL_BASE_DIR/hlr-tester
cp HLR_Tests.cfg $VOL_BASE_DIR/hlr-tester/

# Disable D-GSM tests until osmo-hlr.git release > 1.2.0 is available
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed "s/HLR_Tests.mp_hlr_supports_dgsm := true/HLR_Tests.mp_hlr_supports_dgsm := false/g" -i \
		"$VOL_BASE_DIR/hlr-tester/HLR_Tests.cfg"
fi

mkdir $VOL_BASE_DIR/hlr
cp osmo-hlr.cfg $VOL_BASE_DIR/hlr/

echo Starting container with HLR
docker run	--rm \
		--network $NET_NAME --ip 172.18.10.20 \
		-v $VOL_BASE_DIR/hlr:/data \
		--name ${BUILD_TAG}-hlr -d \
		$REPO_USER/osmo-hlr-$IMAGE_SUFFIX \
		/bin/sh -c "osmo-hlr -c /data/osmo-hlr.cfg >/data/osmo-hlr.log 2>&1"

echo Starting container with HLR testsuite
docker run	--rm \
		--network $NET_NAME --ip 172.18.10.103 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/hlr-tester:/data \
		--name ${BUILD_TAG}-ttcn3-hlr-test \
		$REPO_USER/ttcn3-hlr-test

echo Stopping containers
docker container kill ${BUILD_TAG}-hlr

network_remove
collect_logs
