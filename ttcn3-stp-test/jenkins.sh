#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"ttcn3-stp-test"

mkdir $VOL_BASE_DIR/stp-tester
cp STP_Tests.cfg $VOL_BASE_DIR/stp-tester/

mkdir $VOL_BASE_DIR/stp
cp osmo-stp.cfg $VOL_BASE_DIR/stp/

# Disable IPv6 until libosmo-sccp.git release > 1.3.0 is available
if [ "$IMAGE_SUFFIX" = "latest" ]; then
	sed "/fd02:db8/d" -i "$VOL_BASE_DIR/stp/osmo-stp.cfg"
	sed 's/, "fd02:db8:19::203"//g' -i "$VOL_BASE_DIR/stp-tester/STP_Tests.cfg"
	sed 's/, "fd02:db8:19::200"//g' -i "$VOL_BASE_DIR/stp-tester/STP_Tests.cfg"
fi

SUBNET=19
network_create $SUBNET

echo Starting container with STP
docker run	--rm \
		$(docker_network_params $SUBNET 200) \
		--ulimit core=-1 \
		-v $VOL_BASE_DIR/stp:/data \
		--name ${BUILD_TAG}-stp -d \
		$DOCKER_ARGS \
		$REPO_USER/osmo-stp-$IMAGE_SUFFIX

echo Starting container with STP testsuite
docker run	--rm \
		$(docker_network_params $SUBNET 203) \
		--ulimit core=-1 \
		-e "TTCN3_PCAP_PATH=/data" \
		-v $VOL_BASE_DIR/stp-tester:/data \
		--name ${BUILD_TAG}-ttcn3-stp-test \
		$DOCKER_ARGS \
		$REPO_USER/ttcn3-stp-test "$@"

docker container kill ${BUILD_TAG}-stp

network_remove
collect_logs
